data "google_client_config" "current" {}

locals {
  region      = data.google_client_config.current.region
  name_prefix = "${var.project_id}-platform"
}

################################################################################
# Cloud KMS — Key Ring + Crypto Key
################################################################################

resource "google_kms_key_ring" "secrets" {
  name     = "${local.name_prefix}-secrets"
  project  = var.project_id
  location = local.region
}

resource "google_kms_crypto_key" "secrets" {
  name            = "${local.name_prefix}-secrets-key"
  key_ring        = google_kms_key_ring.secrets.id
  rotation_period = "${var.kms_key_rotation_days * 24 * 60 * 60}s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}

################################################################################
# Secret Manager — Platform Secrets
################################################################################

resource "google_secret_manager_secret" "platform_database_password" {
  secret_id = "${local.name_prefix}-database-password"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    team      = var.team
    component = "secrets"
  }
}

resource "google_secret_manager_secret" "platform_api_key" {
  secret_id = "${local.name_prefix}-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    team      = var.team
    component = "secrets"
  }
}

################################################################################
# Workload Identity — External Secrets Operator
################################################################################

module "external_secrets_platform_wi" {
  source = "../../../modules/gcp/workload-identity"

  role_name       = "${var.project_id}-ext-secrets-platform"
  project_id      = var.project_id
  namespace       = "external-secrets"
  service_account = "external-secrets"

  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudkms.cryptoKeyDecrypter",
  ]
}
