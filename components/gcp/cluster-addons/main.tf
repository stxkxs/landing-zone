locals {
  wi_prefix     = var.cluster_name
  bucket_prefix = var.cluster_name
}

################################################################################
# Workload Identity — external-dns (Cloud DNS admin)
################################################################################

module "external_dns_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${local.wi_prefix}-external-dns"
  project_id      = var.project_id
  namespace       = "external-dns"
  service_account = "external-dns"

  roles = [
    "roles/dns.admin",
  ]
}

################################################################################
# Workload Identity — cert-manager (DNS01 challenges)
################################################################################

module "cert_manager_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${local.wi_prefix}-cert-manager"
  project_id      = var.project_id
  namespace       = "cert-manager"
  service_account = "cert-manager"

  roles = [
    "roles/dns.admin",
  ]
}

################################################################################
# Workload Identity — external-secrets (Secret Manager access)
################################################################################

module "external_secrets_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${local.wi_prefix}-external-secrets"
  project_id      = var.project_id
  namespace       = "external-secrets"
  service_account = "external-secrets"

  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudkms.cryptoKeyDecrypter",
  ]
}

################################################################################
# Workload Identity — Loki (GCS access for log storage)
################################################################################

module "loki_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${local.wi_prefix}-loki"
  project_id      = var.project_id
  namespace       = "monitoring"
  service_account = "loki"

  roles = [
    "roles/storage.objectAdmin",
  ]
}

################################################################################
# Workload Identity — Tempo (GCS access for trace storage)
################################################################################

module "tempo_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${local.wi_prefix}-tempo"
  project_id      = var.project_id
  namespace       = "monitoring"
  service_account = "tempo"

  roles = [
    "roles/storage.objectAdmin",
  ]
}
