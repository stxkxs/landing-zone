output "directory_id" {
  description = "ID of the Entra ID directory"
  value       = var.tenant_id
}

output "management_group_ids" {
  description = "Map of management group names to their IDs"
  value       = { for k, v in azurerm_management_group.this : k => v.id }
}

output "custom_role_ids" {
  description = "Map of custom role names to their definition IDs"
  value       = { for k, v in azurerm_role_definition.this : k => v.role_definition_resource_id }
}
