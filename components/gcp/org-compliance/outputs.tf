output "audit_log_sink_id" {
  description = "The ID of the audit log sink"
  value       = var.enable_audit_logs ? google_logging_organization_sink.audit_logs[0].id : ""
}
