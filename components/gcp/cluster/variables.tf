variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
}

variable "network_id" {
  description = "The ID of the VPC network for the cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets for cluster nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets for load balancers"
  type        = list(string)
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Whether the GKE cluster endpoint is publicly accessible"
  type        = bool
  default     = false
}

variable "system_node_min_size" {
  description = "The minimum number of nodes in the system node pool"
  type        = number
  default     = 1
}

variable "system_node_max_size" {
  description = "The maximum number of nodes in the system node pool"
  type        = number
  default     = 3
}

variable "system_node_disk_size" {
  description = "The disk size in GB for system node pool instances"
  type        = number
  default     = 100
}
