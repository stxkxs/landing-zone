variable "role_name" {
  description = "Name of the GCP service account"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
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

variable "roles" {
  description = "List of IAM roles to grant to the service account"
  type        = list(string)
  default     = []
}
