variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID"
  type        = string
}

variable "enable_scc" {
  description = "Whether to enable Security Command Center"
  type        = bool
  default     = true
}

variable "enable_scc_bigquery_export" {
  description = "Whether to enable SCC findings export to BigQuery"
  type        = bool
  default     = false
}

variable "bigquery_location" {
  description = "The BigQuery dataset location for SCC findings export"
  type        = string
  default     = "US"
}

variable "alert_email_endpoints" {
  description = "The list of email addresses for security alert notifications"
  type        = list(string)
  default     = []
}
