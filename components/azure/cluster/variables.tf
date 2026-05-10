variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
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

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the AKS cluster endpoint"
  type        = bool
  default     = false
}

variable "system_node_min_size" {
  description = "Minimum number of system node pool nodes"
  type        = number
  default     = 1
}

variable "system_node_max_size" {
  description = "Maximum number of system node pool nodes"
  type        = number
  default     = 3
}

variable "system_node_disk_size" {
  description = "Disk size in GB for system node pool nodes"
  type        = number
  default     = 100
}
