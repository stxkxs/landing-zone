data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

################################################################################
# Recovery Services Vault
################################################################################

resource "azurerm_recovery_services_vault" "this" {
  count = var.enable_backup_vault ? 1 : 0

  name                = "${var.resource_group_name}-backup-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = {
    Component = "backup"
    Team      = var.team
  }
}

################################################################################
# Data Protection Backup Vault (for AKS / Kubernetes workloads)
################################################################################

resource "azurerm_data_protection_backup_vault" "this" {
  count = var.enable_backup_vault ? 1 : 0

  name                = "${var.resource_group_name}-dp-vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Component = "backup"
    Team      = var.team
  }
}

################################################################################
# Backup Policy — VM
################################################################################

resource "azurerm_backup_policy_vm" "daily" {
  count = var.enable_backup_vault ? 1 : 0

  name                = "daily-vm-backup"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this[0].name

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }
}

################################################################################
# Backup Policy — AKS (Data Protection)
################################################################################

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "daily" {
  count = var.enable_backup_vault ? 1 : 0

  name                = "daily-aks-backup"
  resource_group_name = var.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.this[0].name

  backup_repeating_time_intervals = ["R/2024-01-01T02:00:00+00:00/P1D"]

  default_retention_rule {
    life_cycle {
      duration        = "P30D"
      data_store_type = "OperationalStore"
    }
  }
}
