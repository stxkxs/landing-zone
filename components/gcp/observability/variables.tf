variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster to monitor"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "enable_cluster_alarms" {
  description = "Whether to enable cluster-level monitoring alarms"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "The number of days to retain logs in Cloud Logging"
  type        = number
  default     = 30
}

variable "alert_email_endpoints" {
  description = "The list of email addresses for alert notifications"
  type        = list(string)
  default     = []
}
