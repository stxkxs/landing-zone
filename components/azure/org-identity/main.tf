data "azurerm_subscription" "current" {}

locals {
  tags = {
    Component = "org-identity"
    Team      = var.team
  }

  # Flatten role assignments: {role_key}-{assignment_index} => {role_key, principal_id, scope}
  role_assignment_map = flatten([
    for role_key, role in var.custom_roles : [
      for idx, assignment in role.assignments : {
        key          = "${role_key}-${idx}"
        role_key     = role_key
        principal_id = assignment.principal_id
        scope        = assignment.scope
      }
    ]
  ])
}

################################################################################
# Management Groups
################################################################################

resource "azurerm_management_group" "this" {
  for_each = var.management_groups

  display_name               = each.value.display_name
  parent_management_group_id = each.value.parent_management_group_id
}

################################################################################
# Custom Role Definitions
################################################################################

resource "azurerm_role_definition" "this" {
  for_each = var.custom_roles

  name        = each.key
  scope       = each.value.scope
  description = each.value.description

  permissions {
    actions          = each.value.permissions.actions
    not_actions      = each.value.permissions.not_actions
    data_actions     = each.value.permissions.data_actions
    not_data_actions = each.value.permissions.not_data_actions
  }

  assignable_scopes = each.value.assignable_scopes
}

################################################################################
# Role Assignments
################################################################################

resource "azurerm_role_assignment" "this" {
  for_each = { for a in local.role_assignment_map : a.key => a }

  scope              = each.value.scope
  role_definition_id = azurerm_role_definition.this[each.value.role_key].role_definition_resource_id
  principal_id       = each.value.principal_id
}
