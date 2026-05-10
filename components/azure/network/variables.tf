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

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "nat_gateways" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 1
}

variable "enable_flow_logs" {
  description = "Enable NSG flow logs"
  type        = bool
  default     = true
}
