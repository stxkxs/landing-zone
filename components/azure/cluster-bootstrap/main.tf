locals {
  tags = {
    Component = "cluster-bootstrap"
    Team      = var.team
  }
}

################################################################################
# Kubernetes & Helm Provider Config (AKS via kubeconfig)
################################################################################

provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "helm" {
  kubernetes = {
    host                   = "https://${var.cluster_endpoint}"
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}
