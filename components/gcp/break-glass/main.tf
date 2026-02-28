locals {
  labels = {
    component   = "break-glass"
    team        = var.team
    break_glass = "true"
  }
}

################################################################################
# Break-Glass Service Account
################################################################################

resource "google_service_account" "break_glass" {
  project      = var.project_id
  account_id   = "break-glass"
  display_name = "Break-Glass Emergency Access"
  description  = "Emergency break-glass service account for incident response"
}

################################################################################
# Break-Glass IAM Custom Role
################################################################################

resource "google_project_iam_custom_role" "break_glass" {
  project     = var.project_id
  role_id     = "breakGlassAdmin"
  title       = "Break-Glass Administrator"
  description = "Emergency administrator role for break-glass access"

  permissions = [
    "compute.instances.list",
    "compute.instances.get",
    "compute.instances.stop",
    "compute.instances.start",
    "compute.instances.setMetadata",
    "container.clusters.get",
    "container.clusters.list",
    "container.clusters.getCredentials",
    "container.pods.list",
    "container.pods.get",
    "container.pods.exec",
    "container.pods.delete",
    "container.deployments.list",
    "container.deployments.get",
    "container.deployments.update",
    "container.services.list",
    "container.services.get",
    "logging.logEntries.list",
    "logging.logs.list",
    "monitoring.timeSeries.list",
    "resourcemanager.projects.get",
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.getAccessToken",
    "storage.buckets.list",
    "storage.objects.list",
    "storage.objects.get",
  ]
}

################################################################################
# IAM Bindings — Service Account gets the custom role on the project
################################################################################

resource "google_project_iam_member" "break_glass_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.break_glass.id
  member  = "serviceAccount:${google_service_account.break_glass.email}"
}

################################################################################
# Trusted Members — who can impersonate the break-glass SA
################################################################################

resource "google_service_account_iam_member" "token_creator" {
  for_each = toset(var.trusted_members)

  service_account_id = google_service_account.break_glass.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

################################################################################
# Audit Logging — log sink for break-glass SA activity
################################################################################

resource "google_logging_project_sink" "break_glass_audit" {
  project                = var.project_id
  name                   = "break-glass-audit"
  destination            = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/_Default"
  filter                 = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.break_glass.email}\""
  unique_writer_identity = true
}

################################################################################
# Alert on Break-Glass Usage
################################################################################

resource "google_monitoring_alert_policy" "break_glass_usage" {
  project      = var.project_id
  display_name = "Break-Glass Service Account Used"
  combiner     = "OR"

  conditions {
    display_name = "Break-glass SA activity detected"

    condition_matched_log {
      filter = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.break_glass.email}\""
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  user_labels = local.labels
}
