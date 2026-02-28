output "addons_installed" {
  description = "List of installed AKS cluster add-ons"
  value = [
    "external-dns",
    "cert-manager",
    "external-secrets",
    "loki",
    "tempo",
  ]
}
