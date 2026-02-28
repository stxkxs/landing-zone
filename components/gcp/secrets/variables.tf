variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "workload_identity_pool" {
  description = "The Workload Identity pool for service account bindings"
  type        = string
}

variable "kms_key_rotation_days" {
  description = "The number of days between automatic KMS key rotations"
  type        = number
  default     = 90
}
