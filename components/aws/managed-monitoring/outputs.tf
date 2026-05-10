################################################################################
# Outputs to wire into eks-gitops:
#   - grafana-agent values-{env}.yaml: amp_remote_write_url, region, IRSA role ARN
#   - dashboards/base: grafana_endpoint
################################################################################

output "amp_workspace_id" {
  description = "AMP workspace ID"
  value       = aws_prometheus_workspace.this.id
}

output "amp_workspace_arn" {
  description = "AMP workspace ARN"
  value       = aws_prometheus_workspace.this.arn
}

output "amp_remote_write_url" {
  description = "AMP remote-write endpoint (paste into eks-gitops grafana-agent values)"
  value       = "${aws_prometheus_workspace.this.prometheus_endpoint}api/v1/remote_write"
}

output "amp_query_endpoint" {
  description = "AMP query endpoint (used as Grafana Prometheus data source URL)"
  value       = aws_prometheus_workspace.this.prometheus_endpoint
}

output "grafana_agent_irsa_role_arn" {
  description = "IRSA role ARN for grafana-agent (annotate the SA with eks.amazonaws.com/role-arn)"
  value       = module.grafana_agent_amp_irsa.iam_role_arn
}

output "grafana_endpoint" {
  description = "Grafana workspace endpoint URL"
  value       = "https://${aws_grafana_workspace.this.endpoint}"
}

output "grafana_workspace_id" {
  description = "Grafana workspace ID"
  value       = aws_grafana_workspace.this.id
}

output "grafana_workspace_arn" {
  description = "Grafana workspace ARN"
  value       = aws_grafana_workspace.this.arn
}
