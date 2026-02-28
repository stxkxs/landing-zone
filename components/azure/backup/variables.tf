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

variable "enable_backup_vault" {
  description = "Whether to create the Azure Backup vault"
  type        = bool
  default     = true
}
