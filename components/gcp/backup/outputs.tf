output "backup_plan_id" {
  description = "The ID of the GKE backup plan"
  value       = var.enable_backup_plan ? google_gke_backup_backup_plan.this[0].id : ""
}
