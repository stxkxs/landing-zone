output "scc_notification_config_id" {
  description = "The ID of the Security Command Center notification config"
  value       = var.enable_scc ? google_scc_notification_config.critical_findings[0].name : ""
}
