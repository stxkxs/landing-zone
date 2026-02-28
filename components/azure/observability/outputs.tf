output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "action_group_ids" {
  description = "List of Action Group IDs for alert routing"
  value       = [azurerm_monitor_action_group.critical.id, azurerm_monitor_action_group.warning.id]
}
