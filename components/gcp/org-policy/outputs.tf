output "policy_ids" {
  description = "The IDs of the organization policy constraints"
  value       = [for p in google_org_policy_policy.boolean : p.name]
}
