output "cost_export_id" {
  description = "ID of the Cost Management export"
  value       = var.enable_cost_export ? azurerm_subscription_cost_management_export.daily[0].id : null
}

output "budget_id" {
  description = "ID of the subscription budget"
  value       = azurerm_consumption_budget_subscription.monthly.id
}

output "action_group_id" {
  description = "ID of the cost alerts action group"
  value       = azurerm_monitor_action_group.cost_alerts.id
}
