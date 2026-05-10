output "defender_plan_ids" {
  description = "List of Defender for Cloud plan IDs"
  value       = [for k, v in azurerm_security_center_subscription_pricing.this : v.id]
}

output "security_contact_id" {
  description = "ID of the Defender for Cloud security contact"
  value       = var.enable_defender ? azurerm_security_center_contact.this[0].id : null
}
