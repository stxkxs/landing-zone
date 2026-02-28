variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "trusted_principal_ids" {
  description = "List of Entra ID principal IDs trusted for break-glass access"
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for break-glass access"
  type        = number
  default     = 3600
}
