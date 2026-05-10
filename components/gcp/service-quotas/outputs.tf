output "quota_alert_policy_ids" {
  description = "The IDs of the quota alert policies"
  value       = [for policy in google_monitoring_alert_policy.quota : policy.id]
}
