output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}

output "app_of_apps_name" {
  description = "Name of the App-of-Apps root Application"
  value       = "app-of-apps"
}

output "gitops_repo_url" {
  description = "Git URL of the GitOps repository the App-of-Apps is tracking"
  value       = var.gitops_repo_url
}
