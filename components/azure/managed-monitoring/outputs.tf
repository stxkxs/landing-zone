################################################################################
# Outputs to wire into aks-gitops:
#   - grafana-agent values-{env}.yaml: amw_remote_write_url, grafana_agent_client_id
#   - dashboards/base: grafana_endpoint (Grafana CR external URL)
################################################################################

output "amw_id" {
  description = "Resource ID of the Azure Monitor Workspace"
  value       = azurerm_monitor_workspace.this.id
}

output "amw_name" {
  description = "Name of the Azure Monitor Workspace"
  value       = azurerm_monitor_workspace.this.name
}

output "amw_remote_write_url" {
  description = "Prometheus remote-write URL for the Azure Monitor Workspace (paste into aks-gitops grafana-agent values)"
  value       = "${azurerm_monitor_workspace.this.query_endpoint}/dataCollectionRules/.../streams/Microsoft-PrometheusMetrics/api/v1/write"
}

output "amw_query_endpoint" {
  description = "Azure Monitor Workspace query endpoint (used as Grafana Prometheus data source URL)"
  value       = azurerm_monitor_workspace.this.query_endpoint
}

output "grafana_agent_client_id" {
  description = "Workload-identity client ID for grafana-agent (annotate the SA with azure.workload.identity/client-id)"
  value       = module.grafana_agent_amw_identity.client_id
}

output "grafana_endpoint" {
  description = "URL of the Azure Managed Grafana instance"
  value       = azurerm_dashboard_grafana.this.endpoint
}

output "grafana_id" {
  description = "Resource ID of the Azure Managed Grafana instance"
  value       = azurerm_dashboard_grafana.this.id
}

output "grafana_name" {
  description = "Name of the Azure Managed Grafana instance"
  value       = azurerm_dashboard_grafana.this.name
}
