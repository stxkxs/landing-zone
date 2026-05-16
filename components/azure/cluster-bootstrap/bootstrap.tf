################################################################################
# Bootstrap: Cilium CNI (Azure CNI overlay with Cilium data plane)
################################################################################

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.6"
  namespace  = "kube-system"

  values = [yamlencode({
    aksbyocni = {
      enabled = true
    }
    nodeinit = {
      enabled = true
    }
    # IPAM mode rationale: "cluster-pool" is the correct choice for pure
    # BYOCNI (network_plugin=none on AKS) where Cilium owns IPAM end-to-end.
    # "delegated-plugin" is for Azure CNI Powered by Cilium — a managed AKS
    # feature where Azure CNS allocates pod IPs and Cilium only handles the
    # data plane. Mixing them up makes the operator's IP-allocator loop fail,
    # which keeps agents from going Ready and cascades to coredns/etc. stuck
    # in ContainerCreating. The pod CIDR here MUST stay disjoint from the
    # VNet CIDR (network component) and the service CIDR (cluster component).
    ipam = {
      mode = "cluster-pool"
      operator = {
        clusterPoolIPv4PodCIDRList = [var.pod_cidr]
        clusterPoolIPv4MaskSize    = 24
      }
    }
    hubble = {
      enabled = true
      relay = {
        enabled = true
      }
      ui = {
        enabled = true
      }
    }
    encryption = {
      enabled = true
      type    = "wireguard"
    }
    bpf = {
      preallocateMaps = true
    }
    operator = {
      replicas = var.cilium_operator_replicas
    }
  })]

  # Helm needs more than 5 min on a fresh BYOCNI cluster: nodes flip Ready
  # only once Cilium agent writes /etc/cni/net.d/05-cilium.conflist, then the
  # operator's leader election, IPAM-init, and Hubble rollout all serialize
  # behind that. 15 min is comfortable.
  timeout = 900

  lifecycle {
    ignore_changes = all
  }
}

################################################################################
# Bootstrap: ArgoCD
################################################################################

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16"
  namespace        = "argocd"
  create_namespace = true

  # Bootstrap-time scheduling: at the moment this runs, the only nodes that
  # exist are the AKS system pool (which carries the `CriticalAddonsOnly`
  # taint). NAP-provisioned worker nodes don't show up until ArgoCD applies
  # the NodePool/AKSNodeClass CRs from aks-gitops — which can't happen until
  # ArgoCD itself is running. So ArgoCD MUST tolerate the system-pool taint
  # for the cold-start. Without this, the chart's pre-install Job
  # (`argocd-redis-secret-init`) sits Pending and Helm times out at 5m.
  # `global.tolerations` cascades to every workload + pre-install hook the
  # chart deploys.
  values = [yamlencode({
    global = {
      tolerations = [{
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      }]
    }
    # Server-side diff: turn on globally because the per-app sync option
    # `ServerSideDiff=true` is silently ignored by ArgoCD 2.13.x; the only
    # path that actually flips the controller to server-side comparison is
    # this argocd-cmd-params-cm key. Needed because Kubernetes 1.34+ added
    # `.status.terminatingReplicas` to Deployment/StatefulSet schemas that
    # ArgoCD's bundled structured-merge-diff doesn't recognize — without
    # server-side diff every Deployment-shipping addon (cilium, cert-manager,
    # external-dns, keda, falco, opencost, reloader…) fails comparison with
    # `field not declared in schema`.
    #
    # The key name is `controller.diff.server.side` (NOT
    # `...server.side.enabled` — some chart docs/blog posts have the older
    # `.enabled` suffix, but the application-controller's env var binds to
    # the suffix-less form: `ARGOCD_APPLICATION_CONTROLLER_SERVER_SIDE_DIFF
    # <- controller.diff.server.side`).
    configs = {
      params = {
        "controller.diff.server.side" = "true"
      }
    }
    server = {
      replicas = var.argocd_server_replicas
    }
    controller = {
      replicas = 1
    }
    repoServer = {
      replicas = var.argocd_repo_replicas
    }
    applicationSet = {
      replicas = var.argocd_appset_replicas
    }
  })]

  timeout = 900

  depends_on = [helm_release.cilium]
}

################################################################################
# ArgoCD Cluster Secret (drives ApplicationSet generators)
#
# Labels are read by aks-gitops ApplicationSets:
#   - environment   → matrix selector for values-{env}.yaml resolution
#   - cluster_name  → Helm parameter clusterName
#   - vnet_name     → Helm parameter vnetName
#   - provider      → multi-cloud disambiguation
################################################################################

resource "kubernetes_secret_v1" "argocd_cluster" {
  metadata {
    name      = "in-cluster"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      "environment"                    = var.environment
      "provider"                       = "azure"
      "cluster_name"                   = var.cluster_name
      "vnet_name"                      = var.vnet_name
    }
  }

  data = {
    name   = "in-cluster"
    server = "https://kubernetes.default.svc"
  }

  depends_on = [helm_release.argocd]
}

################################################################################
# ArgoCD Platform AppProject
################################################################################

resource "kubectl_manifest" "platform_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "platform"
      namespace = "argocd"
    }
    spec = {
      description = "Platform infrastructure addons"
      sourceRepos = ["*"]
      destinations = [{
        server    = "https://kubernetes.default.svc"
        namespace = "*"
      }]
      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  })

  depends_on = [helm_release.argocd]
}

################################################################################
# NOTE — Azure Key Vault ClusterSecretStore
#
# The ClusterSecretStore CR lives in aks-gitops at
# `addons/bootstrap/external-secrets-stores/` and is reconciled by ArgoCD at
# sync wave 1, after External Secrets (wave 0) installs its CRDs. Defining it
# here in tofu would race ArgoCD's reconcile of the external-secrets Helm
# release — kubectl_manifest fails fast on `resource [external-secrets.io/v1/
# ClusterSecretStore] isn't valid for cluster` because the CRD doesn't exist
# yet. GitOps owns CR-of-Helm-installed-CRD; tofu owns Helm releases + the
# ArgoCD root.
################################################################################
# App-of-Apps Root Application
#
# Points ArgoCD at the aks-gitops repo's applicationsets/ directory. ArgoCD
# will reconcile every ApplicationSet found there, which in turn generate
# per-cluster Applications (matrix generator over cluster secrets).
################################################################################

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      annotations = {
        "argocd.argoproj.io/sync-wave" = "-1"
      }
    }
    spec = {
      project = "platform"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_revision
        path           = var.gitops_repo_path
        directory = {
          recurse = true
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "ServerSideApply=true",
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  })

  force_conflicts   = true
  server_side_apply = true

  depends_on = [
    kubectl_manifest.platform_project,
    kubernetes_secret_v1.argocd_cluster,
  ]
}
