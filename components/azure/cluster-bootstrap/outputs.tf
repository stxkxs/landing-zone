output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}
