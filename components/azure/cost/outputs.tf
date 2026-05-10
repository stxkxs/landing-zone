output "budget_id" {
  description = "ID of the Cost Management budget"
  value       = azurerm_consumption_budget_subscription.monthly.id
}
