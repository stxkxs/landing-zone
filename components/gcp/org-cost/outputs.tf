output "billing_dataset_id" {
  description = "The ID of the BigQuery dataset for billing export"
  value       = var.enable_billing_export ? google_bigquery_dataset.billing_export[0].dataset_id : ""
}
