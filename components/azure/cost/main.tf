data "azurerm_subscription" "current" {}

################################################################################
# Resource Group for Cost Management Resources
################################################################################

resource "azurerm_resource_group" "cost" {
  name     = "rg-cost-management"
  location = "westus2"

  tags = {
    Component = "cost"
    Team      = var.team
  }
}

################################################################################
# Action Group for Budget Alerts
################################################################################

resource "azurerm_monitor_action_group" "budget" {
  name                = "budget-alerts"
  resource_group_name = azurerm_resource_group.cost.name
  short_name          = "budget"

  tags = {
    Component = "cost"
    Team      = var.team
  }
}

################################################################################
# Subscription Budget with Threshold Notifications
################################################################################

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "monthly-budget"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.monthly_budget_limit
  time_grain      = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  dynamic "notification" {
    for_each = var.budget_alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value
      threshold_type = notification.value >= 100 ? "Actual" : "Forecasted"
      operator       = "GreaterThanOrEqualTo"

      contact_groups = [azurerm_monitor_action_group.budget.id]
    }
  }

  lifecycle {
    ignore_changes = [time_period]
  }
}
