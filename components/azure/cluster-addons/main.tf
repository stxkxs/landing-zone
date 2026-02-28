locals {
  # Derive resource group from cluster name convention: {rg}-aks
  resource_group_name = trimsuffix(var.cluster_name, "-aks")
  identity_prefix     = "${var.cluster_name}-wi"

  tags = {
    Component = "cluster-addons"
    Team      = var.team
  }
}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = local.resource_group_name
}

################################################################################
# Workload Identity — External DNS
################################################################################

module "external_dns_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-external-dns"
  resource_group  = local.resource_group_name
  location        = data.azurerm_kubernetes_cluster.this.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "external-dns"
  service_account = "external-dns"
  scope           = "/subscriptions/${var.subscription_id}"

  role_assignments = ["DNS Zone Contributor"]

  tags = local.tags
}

################################################################################
# Workload Identity — cert-manager
################################################################################

module "cert_manager_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-cert-manager"
  resource_group  = local.resource_group_name
  location        = data.azurerm_kubernetes_cluster.this.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "cert-manager"
  service_account = "cert-manager"
  scope           = "/subscriptions/${var.subscription_id}"

  role_assignments = ["DNS Zone Contributor"]

  tags = local.tags
}

################################################################################
# Workload Identity — External Secrets Operator
################################################################################

module "external_secrets_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-external-secrets"
  resource_group  = local.resource_group_name
  location        = data.azurerm_kubernetes_cluster.this.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "external-secrets"
  service_account = "external-secrets"
  scope           = "/subscriptions/${var.subscription_id}"

  role_assignments = ["Key Vault Secrets User"]

  tags = local.tags
}

################################################################################
# Workload Identity — Loki (log storage)
################################################################################

module "loki_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-loki"
  resource_group  = local.resource_group_name
  location        = data.azurerm_kubernetes_cluster.this.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "monitoring"
  service_account = "loki"
  scope           = azurerm_storage_account.loki.id

  role_assignments = ["Storage Blob Data Contributor"]

  tags = local.tags
}

################################################################################
# Workload Identity — Tempo (trace storage)
################################################################################

module "tempo_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-tempo"
  resource_group  = local.resource_group_name
  location        = data.azurerm_kubernetes_cluster.this.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "monitoring"
  service_account = "tempo"
  scope           = azurerm_storage_account.tempo.id

  role_assignments = ["Storage Blob Data Contributor"]

  tags = local.tags
}

################################################################################
# Storage Account — Loki (log storage)
################################################################################

resource "azurerm_storage_account" "loki" {
  name                     = "${replace(var.cluster_name, "-", "")}loki"
  resource_group_name      = local.resource_group_name
  location                 = data.azurerm_kubernetes_cluster.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "loki" {
  name                  = "loki-chunks"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}

################################################################################
# Storage Account — Tempo (trace storage)
################################################################################

resource "azurerm_storage_account" "tempo" {
  name                     = "${replace(var.cluster_name, "-", "")}tempo"
  resource_group_name      = local.resource_group_name
  location                 = data.azurerm_kubernetes_cluster.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "tempo" {
  name                  = "tempo-traces"
  storage_account_id    = azurerm_storage_account.tempo.id
  container_access_type = "private"
}
