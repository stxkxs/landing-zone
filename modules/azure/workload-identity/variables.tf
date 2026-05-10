variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for the managed identity"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name"
  type        = string
}

variable "scope" {
  description = "Azure resource scope for role assignments"
  type        = string
  default     = ""
}

variable "role_assignments" {
  description = "List of Azure role names to assign"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the managed identity"
  type        = map(string)
  default     = {}
}
