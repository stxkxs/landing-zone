variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the backup plan"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "enable_backup_plan" {
  description = "Whether to enable the GKE backup plan"
  type        = bool
  default     = true
}
