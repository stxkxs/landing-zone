output "break_glass_role_id" {
  description = "The ID of the break-glass IAM custom role"
  value       = google_project_iam_custom_role.break_glass.id
}
