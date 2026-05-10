locals {
  labels = {
    component = "backup"
    team      = var.team
  }
}

################################################################################
# GKE Backup Plan
################################################################################

resource "google_gke_backup_backup_plan" "this" {
  count = var.enable_backup_plan ? 1 : 0

  project  = var.project_id
  name     = "${var.project_id}-gke-backup"
  cluster  = "projects/${var.project_id}/locations/${var.region}/clusters/${var.project_id}-gke"
  location = var.region

  backup_config {
    include_volume_data = true
    include_secrets     = true

    all_namespaces = true
  }

  backup_schedule {
    cron_schedule = "0 2 * * *"
  }

  retention_policy {
    backup_delete_lock_days = 7
    backup_retain_days      = 30
  }

  labels = local.labels
}
