variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "monthly_budget_limit" {
  description = "Monthly budget limit in the subscription currency"
  type        = number
  default     = 1000
}

variable "budget_alert_thresholds" {
  description = "List of budget percentage thresholds that trigger alerts"
  type        = list(number)
  default     = [80, 100]
}
