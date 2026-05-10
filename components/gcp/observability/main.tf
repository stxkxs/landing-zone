locals {
  labels = {
    component = "observability"
    team      = var.team
  }
}

################################################################################
# Notification Channels
################################################################################

resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.alert_email_endpoints)

  project      = var.project_id
  display_name = "Email - ${each.value}"
  type         = "email"

  labels = {
    email_address = each.value
  }
}

################################################################################
# Log Bucket
################################################################################

resource "google_logging_project_bucket_config" "gke" {
  project        = var.project_id
  location       = "global"
  bucket_id      = "gke-cluster-logs"
  retention_days = var.log_retention_days
  description    = "Log bucket for GKE cluster logs"
}

################################################################################
# Log-Based Metrics
################################################################################

resource "google_logging_metric" "gke_container_restarts" {
  project     = var.project_id
  name        = "gke_container_restarts"
  description = "Count of container restarts in GKE"
  filter      = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\" textPayload=~\"Back-off restarting\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "gke_oom_kills" {
  project     = var.project_id
  name        = "gke_oom_kills"
  description = "Count of OOM-killed containers in GKE"
  filter      = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\" textPayload=~\"OOMKilled\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

################################################################################
# Alert Policies
################################################################################

resource "google_monitoring_alert_policy" "node_cpu_utilization" {
  count = var.enable_cluster_alarms ? 1 : 0

  project      = var.project_id
  display_name = "GKE Node CPU Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > 80% on GKE nodes"

    condition_threshold {
      filter          = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/cpu/allocatable_utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [for ch in google_monitoring_notification_channel.email : ch.id]

  user_labels = local.labels
}

resource "google_monitoring_alert_policy" "node_memory_utilization" {
  count = var.enable_cluster_alarms ? 1 : 0

  project      = var.project_id
  display_name = "GKE Node Memory Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization > 80% on GKE nodes"

    condition_threshold {
      filter          = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/memory/allocatable_utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [for ch in google_monitoring_notification_channel.email : ch.id]

  user_labels = local.labels
}

resource "google_monitoring_alert_policy" "node_not_ready" {
  count = var.enable_cluster_alarms ? 1 : 0

  project      = var.project_id
  display_name = "GKE Node Not Ready"
  combiner     = "OR"

  conditions {
    display_name = "GKE node condition not ready"

    condition_threshold {
      filter          = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/status\" AND metric.labels.status = \"NotReady\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  notification_channels = [for ch in google_monitoring_notification_channel.email : ch.id]

  user_labels = local.labels
}

resource "google_monitoring_alert_policy" "pod_restart_rate" {
  count = var.enable_cluster_alarms ? 1 : 0

  project      = var.project_id
  display_name = "GKE Pod Restart Rate High"
  combiner     = "OR"

  conditions {
    display_name = "Pod restart count > 10 in 5 minutes"

    condition_threshold {
      filter          = "resource.type = \"k8s_container\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/container/restart_count\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  notification_channels = [for ch in google_monitoring_notification_channel.email : ch.id]

  user_labels = local.labels
}

################################################################################
# Dashboard
################################################################################

resource "google_monitoring_dashboard" "gke_overview" {
  project = var.project_id
  dashboard_json = jsonencode({
    displayName = "GKE Cluster Overview - ${var.cluster_name}"
    gridLayout = {
      columns = 2
      widgets = [
        {
          title = "Node CPU Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/cpu/allocatable_utilization\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Node Memory Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/memory/allocatable_utilization\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Pod Count by Namespace"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_pod\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/pod/network/received_bytes_count\""
                  aggregation = {
                    alignmentPeriod    = "300s"
                    perSeriesAligner   = "ALIGN_RATE"
                    crossSeriesReducer = "REDUCE_COUNT"
                    groupByFields      = ["resource.labels.namespace_name"]
                  }
                }
              }
            }]
          }
        },
        {
          title = "Container Restarts"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_container\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/container/restart_count\""
                  aggregation = {
                    alignmentPeriod    = "300s"
                    perSeriesAligner   = "ALIGN_DELTA"
                    crossSeriesReducer = "REDUCE_SUM"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Network Received Bytes"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/network/received_bytes_count\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Network Sent Bytes"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"k8s_node\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/node/network/sent_bytes_count\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        },
      ]
    }
  })
}
