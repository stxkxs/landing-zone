output "quota_alert_ids" {
  description = "List of quota alert IDs"
  value = [
    azurerm_monitor_metric_alert.cpu_quota.id,
    azurerm_monitor_metric_alert.networking_quota.id,
    azurerm_monitor_metric_alert.storage_quota.id,
  ]
}
