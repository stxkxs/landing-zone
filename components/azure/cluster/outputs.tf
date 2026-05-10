output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the AKS cluster"
  value       = coalesce(azurerm_kubernetes_cluster.this.fqdn, azurerm_kubernetes_cluster.this.private_fqdn)
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
