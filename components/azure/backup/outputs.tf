output "backup_vault_id" {
  description = "ID of the Azure Backup vault"
  value       = var.enable_backup_vault ? azurerm_recovery_services_vault.this[0].id : ""
}
