output "argocd_namespace" {
  description = "The Kubernetes namespace where ArgoCD is installed"
  value       = helm_release.argocd.namespace
}
