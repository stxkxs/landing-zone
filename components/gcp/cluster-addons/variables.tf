variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "workload_identity_pool" {
  description = "The Workload Identity pool for the cluster"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}
