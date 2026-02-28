output "addons_installed" {
  description = "The list of add-ons installed on the cluster"
  value = [
    "external-dns",
    "cert-manager",
    "external-secrets",
    "loki",
    "tempo",
  ]
}
