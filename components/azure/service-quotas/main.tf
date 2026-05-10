data "azurerm_subscription" "current" {}

################################################################################
# Resource Group for Quota Monitoring Resources
################################################################################

resource "azurerm_resource_group" "quotas" {
  name     = "rg-service-quotas"
  location = "westus2"

  tags = {
    Component = "service-quotas"
    Team      = var.team
  }
}

################################################################################
# Action Group for Quota Alerts
################################################################################

resource "azurerm_monitor_action_group" "quota_alerts" {
  name                = "quota-usage-alerts"
  resource_group_name = azurerm_resource_group.quotas.name
  short_name          = "quotaalert"

  tags = {
    Component = "service-quotas"
    Team      = var.team
  }
}

################################################################################
# Metric Alerts — Compute Quota Usage
################################################################################

resource "azurerm_monitor_metric_alert" "cpu_quota" {
  name                = "compute-cpu-quota-usage"
  resource_group_name = azurerm_resource_group.quotas.name
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "CPU quota usage exceeds ${var.quota_threshold_percent}%"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Compute/locations/usages"
    metric_name      = "CurrentValue"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.quota_threshold_percent

    dimension {
      name     = "ResourceName"
      operator = "Include"
      values   = ["cores", "standardDSv3Family", "standardDSv5Family"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.quota_alerts.id
  }

  tags = {
    Component = "service-quotas"
    Team      = var.team
  }
}

################################################################################
# Metric Alerts — Networking Quota Usage
################################################################################

resource "azurerm_monitor_metric_alert" "networking_quota" {
  name                = "networking-quota-usage"
  resource_group_name = azurerm_resource_group.quotas.name
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Networking quota usage exceeds ${var.quota_threshold_percent}%"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Network/locations/usages"
    metric_name      = "CurrentValue"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.quota_threshold_percent

    dimension {
      name     = "ResourceName"
      operator = "Include"
      values   = ["VirtualNetworks", "NetworkSecurityGroups", "PublicIPAddresses", "LoadBalancers"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.quota_alerts.id
  }

  tags = {
    Component = "service-quotas"
    Team      = var.team
  }
}

################################################################################
# Metric Alerts — Storage Quota Usage
################################################################################

resource "azurerm_monitor_metric_alert" "storage_quota" {
  name                = "storage-quota-usage"
  resource_group_name = azurerm_resource_group.quotas.name
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Storage account quota usage exceeds ${var.quota_threshold_percent}%"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.quota_threshold_percent
  }

  action {
    action_group_id = azurerm_monitor_action_group.quota_alerts.id
  }

  tags = {
    Component = "service-quotas"
    Team      = var.team
  }
}
