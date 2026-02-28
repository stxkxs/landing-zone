output "notification_channel_ids" {
  description = "The IDs of the Cloud Monitoring notification channels"
  value       = [for ch in google_monitoring_notification_channel.email : ch.id]
}

output "log_bucket_name" {
  description = "The name of the Cloud Logging log bucket"
  value       = google_logging_project_bucket_config.gke.bucket_id
}
