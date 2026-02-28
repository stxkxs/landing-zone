variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "quota_threshold_percent" {
  description = "The percentage threshold for quota usage alerts"
  type        = number
  default     = 80
}
