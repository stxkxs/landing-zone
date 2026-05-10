output "activity_log_profile_id" {
  description = "ID of the Activity Log diagnostic profile"
  value       = var.enable_activity_log ? azurerm_monitor_diagnostic_setting.activity_log[0].id : null
}

output "workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.audit.id
}

output "workspace_customer_id" {
  description = "Workspace ID (customer-facing GUID) of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.audit.workspace_id
}

output "storage_account_id" {
  description = "ID of the audit archive storage account"
  value       = azurerm_storage_account.audit_archive.id
}
