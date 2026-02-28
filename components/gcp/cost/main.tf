locals {
  labels = {
    component = "cost"
    team      = var.team
  }
}

################################################################################
# Data Sources
################################################################################

data "google_project" "this" {
  project_id = var.project_id
}

################################################################################
# Notification Channel for Budget Alerts
################################################################################

resource "google_monitoring_notification_channel" "budget" {
  project      = var.project_id
  display_name = "Budget Alert - ${var.project_id}"
  type         = "email"

  labels = {
    email_address = "budget-alerts@${var.project_id}.iam.gserviceaccount.com"
  }
}

################################################################################
# Pub/Sub Topic for Budget Notifications
################################################################################

resource "google_pubsub_topic" "budget_alerts" {
  project = var.project_id
  name    = "billing-budget-alerts"

  labels = local.labels
}

################################################################################
# Billing Budget
################################################################################

resource "google_billing_budget" "monthly" {
  billing_account = data.google_project.this.billing_account
  display_name    = "${var.project_id}-monthly-budget"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.monthly_budget_limit)
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
    pubsub_topic = google_pubsub_topic.budget_alerts.id
  }
}
