output "managed_zone_name" {
  description = "The name of the Cloud DNS managed zone"
  value       = try(google_dns_managed_zone.primary[0].name, "")
}

output "name_servers" {
  description = "The name servers for the managed zone"
  value       = try(google_dns_managed_zone.primary[0].name_servers, [])
}
