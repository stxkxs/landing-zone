locals {
  labels = {
    component = "service-quotas"
    team      = var.team
  }

  # Key GCP quotas to monitor for a GKE-based platform
  monitored_quotas = {
    gke_clusters = {
      display_name = "GKE Clusters per Project"
      metric       = "container.googleapis.com/clusters"
    }
    cpus_per_region = {
      display_name = "CPUs per Region"
      metric       = "compute.googleapis.com/cpus"
    }
    in_use_ip_addresses = {
      display_name = "In-Use IP Addresses"
      metric       = "compute.googleapis.com/in_use_ip_addresses"
    }
    instance_groups = {
      display_name = "Instance Groups per Project"
      metric       = "compute.googleapis.com/instance_groups"
    }
    persistent_disk_ssd_gb = {
      display_name = "SSD Persistent Disk (GB)"
      metric       = "compute.googleapis.com/ssd_total_storage"
    }
  }
}

################################################################################
# Quota Alert Policies
################################################################################

resource "google_monitoring_alert_policy" "quota" {
  for_each = local.monitored_quotas

  project      = var.project_id
  display_name = "Quota Alert - ${each.value.display_name}"
  combiner     = "OR"

  conditions {
    display_name = "${each.value.display_name} usage > ${var.quota_threshold_percent}%"

    condition_threshold {
      filter          = "resource.type = \"consumer_quota\" AND metric.type = \"serviceruntime.googleapis.com/quota/allocation/usage\" AND metric.labels.quota_metric = \"${each.value.metric}\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.quota_threshold_percent / 100

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MAX"
        group_by_fields      = ["resource.labels.quota_metric"]
      }

      denominator_filter = "resource.type = \"consumer_quota\" AND metric.type = \"serviceruntime.googleapis.com/quota/limit\" AND metric.labels.quota_metric = \"${each.value.metric}\""

      denominator_aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MAX"
        group_by_fields      = ["resource.labels.quota_metric"]
      }
    }
  }

  user_labels = local.labels
}
