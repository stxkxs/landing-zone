variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the GKE cluster API server"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate authority data for the cluster"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "cilium_operator_replicas" {
  description = "The number of Cilium operator replicas"
  type        = number
  default     = 1
}

variable "argocd_server_replicas" {
  description = "The number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "argocd_repo_replicas" {
  description = "The number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "argocd_appset_replicas" {
  description = "The number of ArgoCD ApplicationSet controller replicas"
  type        = number
  default     = 1
}
