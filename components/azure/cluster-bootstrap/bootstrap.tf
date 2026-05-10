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
    ipam = {
      mode = "delegated-plugin"
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

  values = [yamlencode({
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

resource "kubernetes_manifest" "platform_project" {
  manifest = {
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
  }

  depends_on = [helm_release.argocd]
}

################################################################################
# Azure Key Vault ClusterSecretStore (referenced by External Secrets in
# aks-gitops Druid catalog and any other ExternalSecret resources).
#
# This depends on external-secrets being installed by the App-of-Apps
# (wave 0). The CR will reconcile once the CRDs land — the lifecycle
# wait_for_rollout = false in providers ensures plan/apply doesn't block.
################################################################################

resource "kubernetes_manifest" "azure_key_vault_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "azure-key-vault"
    }
    spec = {
      provider = {
        azurekv = {
          authType = "WorkloadIdentity"
          vaultUrl = var.key_vault_uri
          tenantId = var.tenant_id
          serviceAccountRef = {
            name      = "external-secrets"
            namespace = "external-secrets"
          }
        }
      }
    }
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [
    kubernetes_secret_v1.argocd_cluster,
    kubernetes_manifest.app_of_apps,
  ]
}

################################################################################
# App-of-Apps Root Application
#
# Points ArgoCD at the aks-gitops repo's applicationsets/ directory. ArgoCD
# will reconcile every ApplicationSet found there, which in turn generate
# per-cluster Applications (matrix generator over cluster secrets).
################################################################################

resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
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
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [
    kubernetes_manifest.platform_project,
    kubernetes_secret_v1.argocd_cluster,
  ]
}
