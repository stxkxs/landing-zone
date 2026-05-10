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

variable "enable_audit_logs" {
  description = "Whether to enable audit log sinks"
  type        = bool
  default     = true
}

variable "log_bucket_location" {
  description = "The GCS location for the audit log storage bucket"
  type        = string
  default     = "US"
}

variable "log_retention_days" {
  description = "The number of days to retain audit logs before deletion"
  type        = number
  default     = 730
}
