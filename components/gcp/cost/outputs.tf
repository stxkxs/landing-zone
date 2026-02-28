output "budget_id" {
  description = "The ID of the billing budget"
  value       = google_billing_budget.monthly.id
}
