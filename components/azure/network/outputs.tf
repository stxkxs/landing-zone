output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = azurerm_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = azurerm_subnet.public[*].id
}

output "nat_public_ips" {
  description = "Public IP addresses attached to NAT Gateways. Used as the cluster's egress IPs — must be added to AKS api_authorized_ip_ranges so node→API-server traffic isn't blocked by the allowlist."
  value       = azurerm_public_ip.nat[*].ip_address
}
