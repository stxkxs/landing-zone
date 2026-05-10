data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

################################################################################
# Log Analytics Workspace
################################################################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

################################################################################
# AKS Diagnostic Setting
################################################################################

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.cluster_name}-diagnostics"
  target_resource_id         = data.azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

################################################################################
# Action Groups
################################################################################

resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.cluster_name}-critical"
  resource_group_name = var.resource_group_name
  short_name          = "critical"

  dynamic "email_receiver" {
    for_each = var.alert_email_endpoints
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

resource "azurerm_monitor_action_group" "warning" {
  name                = "${var.cluster_name}-warning"
  resource_group_name = var.resource_group_name
  short_name          = "warning"

  dynamic "email_receiver" {
    for_each = var.alert_email_endpoints
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

################################################################################
# Metric Alerts — AKS Cluster Health
################################################################################

resource "azurerm_monitor_metric_alert" "node_cpu_utilization" {
  count = var.enable_cluster_alarms ? 1 : 0

  name                = "${var.cluster_name}-node-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_kubernetes_cluster.this.id]
  description         = "AKS node CPU utilization exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "cpuUsagePercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

resource "azurerm_monitor_metric_alert" "node_memory_utilization" {
  count = var.enable_cluster_alarms ? 1 : 0

  name                = "${var.cluster_name}-node-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_kubernetes_cluster.this.id]
  description         = "AKS node memory utilization exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "memoryWorkingSetPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

resource "azurerm_monitor_metric_alert" "node_not_ready" {
  count = var.enable_cluster_alarms ? 1 : 0

  name                = "${var.cluster_name}-node-not-ready"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_kubernetes_cluster.this.id]
  description         = "AKS cluster has nodes in NotReady state"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "cluster_autoscaler_unschedulable_pods_count"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

resource "azurerm_monitor_metric_alert" "pod_restart_count" {
  count = var.enable_cluster_alarms ? 1 : 0

  name                = "${var.cluster_name}-pod-restarts-high"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_kubernetes_cluster.this.id]
  description         = "High pod restart rate in AKS cluster"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "restartingContainerCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}

resource "azurerm_monitor_metric_alert" "api_server_latency" {
  count = var.enable_cluster_alarms ? 1 : 0

  name                = "${var.cluster_name}-api-server-latency"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_kubernetes_cluster.this.id]
  description         = "AKS API server request latency is elevated"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "apiserver_current_inflight_requests"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = {
    Component = "observability"
    Team      = var.team
  }
}
