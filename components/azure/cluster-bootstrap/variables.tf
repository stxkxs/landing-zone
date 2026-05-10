variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID (used by ClusterSecretStore for Azure Key Vault)"
  type        = string
}

variable "location" {
  description = "Azure region of the AKS cluster"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev, staging, production) - used as cluster-secret label and ApplicationSet matrix selector"
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

variable "vnet_name" {
  description = "Name of the AKS VNet (passed as Helm parameter to addons via cluster-secret label)"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the Azure Key Vault that External Secrets reads from"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "gitops_repo_url" {
  description = "Git URL of the AKS GitOps repository"
  type        = string
  default     = "https://github.com/stxkxs/aks-gitops.git"
}

variable "gitops_repo_revision" {
  description = "Git branch or tag to track in the GitOps repository"
  type        = string
  default     = "main"
}

variable "gitops_repo_path" {
  description = "Path within the GitOps repository that contains ApplicationSet manifests"
  type        = string
  default     = "applicationsets"
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
