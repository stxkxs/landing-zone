output "addons_installed" {
  description = "List of addon-related Azure resources provisioned by this component"
  value = [
    "external-dns",
    "cert-manager",
    "external-secrets",
    "loki",
    "tempo",
    "opencost",
    "keda",
    "argo-events",
    "argo-workflows",
    "velero",
  ]
}

################################################################################
# Workload identity client IDs — paste into aks-gitops values-{env}.yaml under
# each addon's serviceAccount.annotations[azure.workload.identity/client-id].
################################################################################

output "workload_identity_client_ids" {
  description = "Map of addon -> workload identity client_id (paste into aks-gitops values-{env}.yaml)"
  value = {
    external-dns     = module.external_dns_identity.client_id
    cert-manager     = module.cert_manager_identity.client_id
    external-secrets = module.external_secrets_identity.client_id
    loki             = module.loki_identity.client_id
    tempo            = module.tempo_identity.client_id
    opencost         = module.opencost_identity.client_id
    keda             = module.keda_identity.client_id
    argo-events      = module.argo_events_identity.client_id
    argo-workflows   = module.argo_workflows_identity.client_id
    velero           = module.velero_identity.client_id
  }
}

################################################################################
# Storage account names — paste into aks-gitops values-{env}.yaml under
# velero.configuration.backupStorageLocation.config.storageAccount and
# argo-workflows.artifactRepository.azure.endpoint.
################################################################################

output "storage_accounts" {
  description = "Storage accounts created for addon use"
  value = {
    loki           = azurerm_storage_account.loki.name
    tempo          = azurerm_storage_account.tempo.name
    velero         = azurerm_storage_account.velero.name
    argo_workflows = azurerm_storage_account.argo_workflows.name
  }
}

output "node_resource_group" {
  description = "AKS node resource group (MC_*) - referenced by Velero volumeSnapshotLocation"
  value       = data.azurerm_kubernetes_cluster.this.node_resource_group
}
