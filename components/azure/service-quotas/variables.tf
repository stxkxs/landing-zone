variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "quota_threshold_percent" {
  description = "Percentage threshold for quota usage alerts"
  type        = number
  default     = 80
}
