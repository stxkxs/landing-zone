variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "billing_account_id" {
  description = "The GCP billing account ID for export configuration"
  type        = string
  default     = ""
}

variable "enable_billing_export" {
  description = "Whether to enable billing export to BigQuery"
  type        = bool
  default     = true
}

variable "bigquery_location" {
  description = "The BigQuery dataset location for billing export"
  type        = string
  default     = "US"
}

variable "org_budget_limit" {
  description = "The org-wide monthly budget limit in USD"
  type        = number
  default     = 10000
}

variable "budget_alert_thresholds" {
  description = "The list of budget threshold percentages that trigger alerts"
  type        = list(number)
  default     = [50, 80, 100, 120]
}

variable "enable_notification_channel" {
  description = "Whether to create a monitoring notification channel for budget alerts"
  type        = bool
  default     = true
}

variable "budget_alert_email" {
  description = "The email address for budget alert notifications"
  type        = string
  default     = ""
}
