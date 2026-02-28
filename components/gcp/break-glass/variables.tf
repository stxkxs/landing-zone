variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "trusted_members" {
  description = "The list of IAM members trusted for break-glass access"
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "The maximum session duration in seconds for break-glass access"
  type        = number
  default     = 3600
}
