variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "monthly_budget_limit" {
  description = "The monthly budget limit in USD"
  type        = number
  default     = 1000
}

variable "budget_alert_thresholds" {
  description = "The list of budget threshold percentages that trigger alerts"
  type        = list(number)
  default     = [80, 100]
}
