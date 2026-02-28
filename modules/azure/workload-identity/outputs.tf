output "identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.this.client_id
}
