################################################################################
# Outputs to wire into aks-gitops catalog/druid/tenants/<tenant>/values.yaml
################################################################################

output "tenant_name" {
  description = "Druid tenant name"
  value       = var.tenant_name
}

output "k8s_namespace" {
  description = "Kubernetes namespace where the Druid tenant runs"
  value       = local.k8s_namespace
}

output "storage_account_name" {
  description = "Druid storage account name (use as azure.storageAccount in tenant values.yaml)"
  value       = azurerm_storage_account.this.name
}

output "deep_storage_container" {
  description = "Container name for Druid deep storage segments"
  value       = azurerm_storage_container.deep_storage.name
}

output "index_logs_container" {
  description = "Container name for Druid indexing task logs"
  value       = azurerm_storage_container.index_logs.name
}

output "msq_container" {
  description = "Container name for Druid multi-stage query intermediate storage"
  value       = azurerm_storage_container.msq.name
}

output "postgres_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgres_database" {
  description = "Name of the Druid metadata database"
  value       = azurerm_postgresql_flexible_server_database.druid.name
}

output "secret_name_metadata" {
  description = "Key Vault secret name for Druid metadata-store credentials (use as secrets.metadata in tenant values.yaml)"
  value       = azurerm_key_vault_secret.metadata.name
}

output "secret_name_admin" {
  description = "Key Vault secret name for Druid admin credentials (use as secrets.admin in tenant values.yaml)"
  value       = azurerm_key_vault_secret.admin.name
}

output "secret_name_system" {
  description = "Key Vault secret name for Druid system credentials (use as secrets.system in tenant values.yaml)"
  value       = azurerm_key_vault_secret.system.name
}

output "service_account_client_ids" {
  description = "Map of Druid component service account -> workload identity client_id (paste into tenant values.yaml under serviceAccounts)"
  value = {
    druid-historical   = module.druid_historical_identity.client_id
    druid-overlord     = module.druid_overlord_identity.client_id
    druid-broker       = module.druid_broker_identity.client_id
    druid-kafka-client = module.druid_kafka_client_identity.client_id
  }
}
