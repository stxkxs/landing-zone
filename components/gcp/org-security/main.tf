locals {
  labels = {
    component = "org-security"
    team      = var.team
  }
}

################################################################################
# Pub/Sub Topic — Security Alerts
################################################################################

resource "google_pubsub_topic" "security_alerts" {
  count = var.enable_scc ? 1 : 0

  name    = "org-security-alerts"
  project = var.project_id
  labels  = local.labels
}

resource "google_pubsub_subscription" "security_alerts" {
  count = var.enable_scc ? 1 : 0

  name    = "org-security-alerts-push"
  project = var.project_id
  topic   = google_pubsub_topic.security_alerts[0].id

  message_retention_duration = "604800s"
  ack_deadline_seconds       = 60

  expiration_policy {
    ttl = ""
  }

  labels = local.labels
}

################################################################################
# SCC Notification Config — Critical/High Findings
################################################################################

resource "google_scc_notification_config" "critical_findings" {
  count = var.enable_scc ? 1 : 0

  config_id    = "org-critical-findings"
  organization = var.org_id
  description  = "Notifications for critical and high severity Security Command Center findings"

  pubsub_topic = google_pubsub_topic.security_alerts[0].id

  streaming_config {
    filter = "severity = \"CRITICAL\" OR severity = \"HIGH\""
  }
}

################################################################################
# SCC BigQuery Export — All Findings
################################################################################

resource "google_bigquery_dataset" "scc_findings" {
  count = var.enable_scc && var.enable_scc_bigquery_export ? 1 : 0

  dataset_id    = "scc_findings"
  project       = var.project_id
  friendly_name = "SCC Findings Export"
  description   = "BigQuery dataset for Security Command Center findings export"
  location      = var.bigquery_location

  delete_contents_on_destroy = false

  labels = local.labels
}

resource "google_scc_organization_scc_big_query_export" "findings" {
  count = var.enable_scc && var.enable_scc_bigquery_export ? 1 : 0

  big_query_export_id = "org-scc-findings-export"
  organization        = var.org_id
  dataset             = google_bigquery_dataset.scc_findings[0].id
  description         = "Export all SCC findings to BigQuery for analysis"
  filter              = ""
}

################################################################################
# Monitoring Notification Channel — Security Alerts
################################################################################

resource "google_monitoring_notification_channel" "security_email" {
  for_each = toset(var.alert_email_endpoints)

  project      = var.project_id
  display_name = "security-alert-${each.value}"
  type         = "email"

  labels = {
    email_address = each.value
  }
}
