locals {
  cluster_name = "${var.resource_group_name}-aks"

  tags = {
    Component = "cluster"
    Team      = var.team
  }
}

################################################################################
# Resource Group
################################################################################

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

################################################################################
# Log Analytics Workspace (for Container Insights)
################################################################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${local.cluster_name}-logs"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

################################################################################
# AKS Cluster
################################################################################

resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  dns_prefix          = local.cluster_name

  kubernetes_version        = "1.31"
  sku_tier                  = "Standard"
  private_cluster_enabled   = !var.cluster_endpoint_public_access
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin     = "azure"
    network_policy     = "cilium"
    network_data_plane = "cilium"
    load_balancer_sku  = "standard"
    outbound_type      = "userAssignedNATGateway"
  }

  default_node_pool {
    name                 = "system"
    vm_size              = "Standard_D4s_v5"
    os_disk_size_gb      = var.system_node_disk_size
    vnet_subnet_id       = var.private_subnet_ids[0]
    auto_scaling_enabled = true
    min_count            = var.system_node_min_size
    max_count            = var.system_node_max_size

    only_critical_addons_enabled = true

    node_labels = {
      "node-role" = "system"
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = var.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = local.tags
}
