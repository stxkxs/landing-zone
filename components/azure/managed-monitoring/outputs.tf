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
  description = "Prometheus remote-write URL for the Azure Monitor Workspace. Uses the DCE's METRICS-ingestion endpoint (not logs!) — these are two distinct hostnames on the same DCE. For metrics like Prometheus samples the host is `<dce>-<hash>.<region>-1.metrics.ingest.monitor.azure.com`; for logs it's `.ingest.monitor.azure.com` without the `.metrics.` segment. Sending Prometheus data to the logs endpoint returns 400 InvalidRequestPath."
  value       = "${azurerm_monitor_data_collection_endpoint.amw.metrics_ingestion_endpoint}/dataCollectionRules/${azurerm_monitor_data_collection_rule.amw.immutable_id}/streams/Microsoft-PrometheusMetrics/api/v1/write?api-version=2023-04-24"
}

output "dce_logs_ingestion_endpoint" {
  description = "Data Collection Endpoint logs ingestion URL — used for logs streams (Microsoft-Syslog, custom tables). NOT for Prometheus metrics; see amw_remote_write_url for that."
  value       = azurerm_monitor_data_collection_endpoint.amw.logs_ingestion_endpoint
}

output "dce_metrics_ingestion_endpoint" {
  description = "Data Collection Endpoint metrics ingestion URL — the base of amw_remote_write_url. Hostname contains a literal `.metrics.` segment that distinguishes it from the logs endpoint on the same DCE."
  value       = azurerm_monitor_data_collection_endpoint.amw.metrics_ingestion_endpoint
}

output "dcr_immutable_id" {
  description = "Data Collection Rule immutable ID (path segment in the remote-write URL)"
  value       = azurerm_monitor_data_collection_rule.amw.immutable_id
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
