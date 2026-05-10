locals {
  labels = {
    component = "org-cost"
    team      = var.team
  }
}

################################################################################
# BigQuery Dataset — Billing Export
################################################################################

resource "google_bigquery_dataset" "billing_export" {
  count = var.enable_billing_export ? 1 : 0

  dataset_id    = "org_billing_export"
  project       = var.project_id
  friendly_name = "Organization Billing Export"
  description   = "BigQuery dataset for GCP billing data export"
  location      = var.bigquery_location

  default_table_expiration_ms     = null
  default_partition_expiration_ms = null
  delete_contents_on_destroy      = false

  labels = local.labels
}

################################################################################
# Billing Budget — Org-Wide Monthly
################################################################################

resource "google_billing_budget" "org_monthly" {
  billing_account = var.billing_account_id
  display_name    = "org-monthly-budget"

  budget_filter {
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.org_budget_limit)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.budget_alert_thresholds
    content {
      threshold_percent = threshold_rules.value / 100
      spend_basis       = threshold_rules.value >= 100 ? "CURRENT_SPEND" : "FORECASTED_SPEND"
    }
  }

  all_updates_rule {
    monitoring_notification_channels = var.enable_notification_channel ? [google_monitoring_notification_channel.budget_alerts[0].id] : []
    disable_default_iam_recipients   = false
  }
}

################################################################################
# Monitoring Notification Channel — Budget Alerts
################################################################################

resource "google_monitoring_notification_channel" "budget_alerts" {
  count = var.enable_notification_channel ? 1 : 0

  project      = var.project_id
  display_name = "org-budget-alerts"
  type         = "email"

  labels = {
    email_address = var.budget_alert_email
  }
}
