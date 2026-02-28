output "break_glass_role_assignment_ids" {
  description = "List of RBAC role assignment IDs for break-glass access"
  value       = [azurerm_role_assignment.break_glass_owner.id]
}
