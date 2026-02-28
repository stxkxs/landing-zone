output "virtual_wan_id" {
  description = "ID of the Azure Virtual WAN"
  value       = var.enable_virtual_wan ? azurerm_virtual_wan.this[0].id : null
}

output "virtual_hub_id" {
  description = "ID of the Azure Virtual Hub"
  value       = var.enable_virtual_wan ? azurerm_virtual_hub.this[0].id : null
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to their IDs"
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}
