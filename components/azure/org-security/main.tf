locals {
  tags = {
    Component = "org-security"
    Team      = var.team
  }

  # Defender plan types to enable
  defender_plans = var.enable_defender ? var.defender_plan_types : []
}

################################################################################
# Microsoft Defender for Cloud — Pricing Plans
################################################################################

resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = toset(local.defender_plans)

  tier          = "Standard"
  resource_type = each.value
}

################################################################################
# Security Contact — Alert Notifications
################################################################################

resource "azurerm_security_center_contact" "this" {
  count = var.enable_defender ? 1 : 0

  name                = "org-security-contact"
  email               = var.security_contact_email
  phone               = var.security_contact_phone
  alert_notifications = true
  alerts_to_admins    = true
}

################################################################################
# Log Analytics Workspace — Defender Data Export
################################################################################

resource "azurerm_security_center_workspace" "this" {
  count = var.enable_defender && var.log_analytics_workspace_id != null ? 1 : 0

  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = var.log_analytics_workspace_id
}
