################################################################################
# Bootstrap: ArgoCD
################################################################################

# Note: GKE Dataplane V2 provides Cilium-based networking natively.
# No separate Cilium installation is required.

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.5"
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
      "project_id"                     = var.project_id
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
