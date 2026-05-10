locals {
  resource_group_name = trimsuffix(var.cluster_name, "-aks")
  amw_name            = "${var.cluster_name}-amw"
  grafana_name        = "${var.cluster_name}-grafana"
  identity_prefix     = "${var.cluster_name}-wi"

  tags = {
    Component = "managed-monitoring"
    Team      = var.team
  }
}

data "azurerm_resource_group" "this" {
  name = local.resource_group_name
}

################################################################################
# Azure Monitor Workspace (managed Prometheus)
################################################################################

resource "azurerm_monitor_workspace" "this" {
  name                = local.amw_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  tags = local.tags
}

################################################################################
# Workload Identity — grafana-agent remote-write into AMW
#
# Grafana Agent in the cluster (running with this UAMI) calls the AMW
# remote-write endpoint with the AAD token. Needs Monitoring Metrics
# Publisher role on the workspace.
################################################################################

module "grafana_agent_amw_identity" {
  source = "../../../modules/azure/workload-identity"

  identity_name   = "${local.identity_prefix}-grafana-agent-amw"
  resource_group  = local.resource_group_name
  location        = var.location
  oidc_issuer_url = var.oidc_issuer_url
  namespace       = "monitoring"
  service_account = "grafana-agent"
  scope           = azurerm_monitor_workspace.this.id

  role_assignments = ["Monitoring Metrics Publisher"]

  tags = local.tags
}

################################################################################
# Azure Managed Grafana
#
# - System-assigned identity is used to authenticate to AMW + Azure Monitor.
# - public_network_access_enabled = true so the AMG endpoint is reachable.
#   (Set to false and add private endpoint for production hardening.)
# - api_key_enabled = true so we can issue a service-account-style token to
#   the in-cluster grafana-operator (so it can push GrafanaDashboard CRs).
################################################################################

resource "azurerm_dashboard_grafana" "this" {
  name                              = local.grafana_name
  resource_group_name               = data.azurerm_resource_group.this.name
  location                          = var.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  grafana_major_version             = "11"
  sku                               = var.grafana_sku
  zone_redundancy_enabled           = var.grafana_zone_redundancy_enabled

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this.id
  }

  tags = local.tags
}

################################################################################
# RBAC — Grafana system identity reads from AMW + Azure Monitor
################################################################################

resource "azurerm_role_assignment" "grafana_amw_reader" {
  scope                = azurerm_monitor_workspace.this.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_subscription_monitoring_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

################################################################################
# RBAC — Human users on Grafana
################################################################################

resource "azurerm_role_assignment" "grafana_admins" {
  for_each             = toset(var.grafana_admin_object_ids)
  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Admin"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "grafana_editors" {
  for_each             = toset(var.grafana_editor_object_ids)
  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Editor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "grafana_viewers" {
  for_each             = toset(var.grafana_viewer_object_ids)
  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Viewer"
  principal_id         = each.value
}
