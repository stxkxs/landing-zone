locals {
  labels = {
    component = "org-networking"
    team      = var.team
  }
}

################################################################################
# Shared VPC Host Project
################################################################################

resource "google_compute_shared_vpc_host_project" "this" {
  count = var.enable_shared_vpc ? 1 : 0

  project = var.project_id
}

################################################################################
# Shared VPC Network
################################################################################

resource "google_compute_network" "shared_vpc" {
  count = var.enable_shared_vpc ? 1 : 0

  name                    = "org-shared-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  depends_on = [google_compute_shared_vpc_host_project.this]
}

################################################################################
# Service Project Attachments
################################################################################

resource "google_compute_shared_vpc_service_project" "this" {
  for_each = var.enable_shared_vpc ? toset(var.service_project_ids) : toset([])

  host_project    = var.project_id
  service_project = each.value

  depends_on = [google_compute_shared_vpc_host_project.this]
}

################################################################################
# Private DNS Zone — Inter-Project Resolution
################################################################################

resource "google_dns_managed_zone" "private" {
  for_each = var.enable_shared_vpc ? var.private_dns_zones : {}

  name        = each.key
  project     = var.project_id
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.shared_vpc[0].id
    }
  }

  labels = local.labels
}

################################################################################
# DNS Policy — Inbound Forwarding
################################################################################

resource "google_dns_policy" "inbound_forwarding" {
  count = var.enable_shared_vpc && var.enable_dns_inbound_forwarding ? 1 : 0

  name                      = "org-inbound-forwarding"
  project                   = var.project_id
  enable_inbound_forwarding = true
  enable_logging            = true

  networks {
    network_url = google_compute_network.shared_vpc[0].id
  }
}

################################################################################
# Firewall Rules — Shared VPC Baseline
################################################################################

resource "google_compute_firewall" "deny_all_ingress" {
  count = var.enable_shared_vpc ? 1 : 0

  name        = "org-deny-all-ingress"
  project     = var.project_id
  network     = google_compute_network.shared_vpc[0].name
  description = "Default deny all ingress traffic"
  direction   = "INGRESS"
  priority    = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  count = var.enable_shared_vpc ? 1 : 0

  name        = "org-allow-internal"
  project     = var.project_id
  network     = google_compute_network.shared_vpc[0].name
  description = "Allow internal traffic between subnets"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.internal_cidr_ranges
}
