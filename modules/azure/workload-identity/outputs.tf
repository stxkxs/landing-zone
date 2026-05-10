output "identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the user-assigned managed identity (used as the workload-identity client_id annotation on the Kubernetes ServiceAccount)"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Object (principal) ID of the user-assigned managed identity (used for additional role assignments outside the module)"
  value       = azurerm_user_assigned_identity.this.principal_id
}
