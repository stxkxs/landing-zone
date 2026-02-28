output "service_account_email" {
  description = "Email of the GCP service account"
  value       = google_service_account.this.email
}

output "service_account_id" {
  description = "Unique ID of the GCP service account"
  value       = google_service_account.this.unique_id
}
