output "dns_zone_id" {
  description = "ID of the Azure DNS zone"
  value       = try(azurerm_dns_zone.this[0].id, null)
}

output "name_servers" {
  description = "List of name servers for the DNS zone"
  value       = try(azurerm_dns_zone.this[0].name_servers, [])
}
