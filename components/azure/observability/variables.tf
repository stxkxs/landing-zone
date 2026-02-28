variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "enable_cluster_alarms" {
  description = "Enable metric alarms for the AKS cluster"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "alert_email_endpoints" {
  description = "List of email addresses for alert notifications"
  type        = list(string)
  default     = []
}
