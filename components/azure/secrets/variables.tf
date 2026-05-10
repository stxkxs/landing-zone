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

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation"
  type        = string
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vault items"
  type        = number
  default     = 90
}
