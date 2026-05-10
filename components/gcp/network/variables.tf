variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "nat_gateways" {
  description = "The number of Cloud NAT gateways to provision"
  type        = number
  default     = 1
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs on subnets"
  type        = bool
  default     = true
}

variable "enable_private_google_access" {
  description = "Whether to enable Private Google Access on subnets"
  type        = bool
  default     = true
}
