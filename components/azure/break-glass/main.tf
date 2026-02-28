data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

################################################################################
# Resource Group for Break-Glass Resources
################################################################################

resource "azurerm_resource_group" "break_glass" {
  name     = "rg-break-glass"
  location = "westus2"

  tags = {
    Component  = "break-glass"
    Team       = var.team
    BreakGlass = "true"
  }
}

################################################################################
# User-Assigned Managed Identity — Break-Glass
################################################################################

resource "azurerm_user_assigned_identity" "break_glass" {
  name                = "break-glass-identity"
  location            = azurerm_resource_group.break_glass.location
  resource_group_name = azurerm_resource_group.break_glass.name

  tags = {
    Component  = "break-glass"
    Team       = var.team
    BreakGlass = "true"
  }
}

################################################################################
# Owner Role Assignment — Emergency Access
################################################################################

resource "azurerm_role_assignment" "break_glass_owner" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.break_glass.principal_id
  description          = "Break-glass emergency Owner access"
}

################################################################################
# Role Assignments for Trusted Principals
################################################################################

resource "azurerm_role_assignment" "trusted_principals" {
  for_each = toset(var.trusted_principal_ids)

  scope                            = "/subscriptions/${var.subscription_id}"
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = each.value
  skip_service_principal_aad_check = true
  description                      = "Allow trusted principal to use break-glass identity"
}

################################################################################
# Activity Log Alert — Break-Glass Usage Detection
################################################################################

resource "azurerm_monitor_activity_log_alert" "break_glass_usage" {
  name                = "break-glass-usage-alert"
  resource_group_name = azurerm_resource_group.break_glass.name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Alert when break-glass managed identity is used"

  criteria {
    category = "Administrative"
    caller   = azurerm_user_assigned_identity.break_glass.principal_id
  }

  tags = {
    Component  = "break-glass"
    Team       = var.team
    BreakGlass = "true"
  }
}
