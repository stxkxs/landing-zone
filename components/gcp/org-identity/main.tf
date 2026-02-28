locals {
  labels = {
    component = "org-identity"
    team      = var.team
  }
}

################################################################################
# Workforce Identity Pool
################################################################################

resource "google_iam_workforce_pool" "this" {
  workforce_pool_id = "org-workforce-pool"
  parent            = "organizations/${var.org_id}"
  location          = "global"
  display_name      = "Organization Workforce Pool"
  description       = "Workforce Identity pool for org-level SSO federation"
  disabled          = false

  session_duration = var.session_duration
}

################################################################################
# Workforce Identity Pool Provider (OIDC)
################################################################################

resource "google_iam_workforce_pool_provider" "oidc" {
  count = var.oidc_issuer_uri != "" ? 1 : 0

  workforce_pool_id = google_iam_workforce_pool.this.workforce_pool_id
  location          = "global"
  provider_id       = "org-oidc-provider"
  display_name      = "Organization OIDC Provider"
  description       = "OIDC identity provider for workforce federation"

  attribute_mapping   = var.attribute_mapping
  attribute_condition = var.attribute_condition != "" ? var.attribute_condition : null

  oidc {
    issuer_uri = var.oidc_issuer_uri
    client_id  = var.oidc_client_id

    web_sso_config {
      response_type             = "CODE"
      assertion_claims_behavior = "MERGE_USER_INFO_OVER_ID_TOKEN_CLAIMS"
    }
  }
}

################################################################################
# Organization IAM Bindings
################################################################################

resource "google_organization_iam_member" "org_admins" {
  for_each = var.org_iam_bindings

  org_id = var.org_id
  role   = each.value.role
  member = each.value.member
}
