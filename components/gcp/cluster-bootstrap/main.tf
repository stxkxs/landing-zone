################################################################################
# Kubernetes & Helm Provider Config (GKE)
################################################################################

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token                  = data.google_client_config.current.access_token
  }
}
