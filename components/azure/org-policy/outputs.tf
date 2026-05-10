output "policy_assignment_ids" {
  description = "List of Azure Policy assignment IDs"
  value = concat(
    var.enable_guardrails_initiative ? [azurerm_management_group_policy_assignment.guardrails[0].id] : [],
    [for k, v in azurerm_management_group_policy_assignment.standalone : v.id]
  )
}

output "policy_definition_ids" {
  description = "Map of custom policy definition names to their IDs"
  value       = { for k, v in azurerm_policy_definition.this : k => v.id }
}

output "policy_set_definition_id" {
  description = "ID of the guardrails policy set definition"
  value       = var.enable_guardrails_initiative ? azurerm_policy_set_definition.guardrails[0].id : null
}
