variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint URL of the AKS cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the AKS cluster"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "cilium_operator_replicas" {
  description = "Number of Cilium operator replicas"
  type        = number
  default     = 1
}

variable "argocd_server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "argocd_repo_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "argocd_appset_replicas" {
  description = "Number of ArgoCD ApplicationSet controller replicas"
  type        = number
  default     = 1
}
