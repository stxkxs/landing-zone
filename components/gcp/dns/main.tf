################################################################################
# Cloud DNS — Public Managed Zone
################################################################################

resource "google_dns_managed_zone" "primary" {
  count = var.create_managed_zone ? 1 : 0

  name        = replace(var.domain_name, ".", "-")
  project     = var.project_id
  dns_name    = "${var.domain_name}."
  description = "Primary managed zone for ${var.domain_name}"
  visibility  = "public"

  dynamic "dnssec_config" {
    for_each = var.enable_dnssec ? [1] : []
    content {
      state = "on"

      default_key_specs {
        algorithm  = "rsasha256"
        key_length = 2048
        key_type   = "keySigning"
      }

      default_key_specs {
        algorithm  = "rsasha256"
        key_length = 1024
        key_type   = "zoneSigning"
      }
    }
  }

  labels = {
    team      = var.team
    component = "dns"
  }
}
