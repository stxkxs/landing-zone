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
################################################################################

resource "kubernetes_secret_v1" "argocd_cluster" {
  metadata {
    name      = "in-cluster"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      "cluster_name"                   = var.cluster_name
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
