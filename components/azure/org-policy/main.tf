data "azurerm_subscription" "current" {}

locals {
  tags = {
    Component = "org-policy"
    Team      = var.team
  }
}

################################################################################
# Custom Policy Definitions
################################################################################

resource "azurerm_policy_definition" "this" {
  for_each = var.policy_definitions

  name                = each.key
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = each.value.management_group_id
  policy_rule         = each.value.policy_rule
  parameters          = each.value.parameters
  metadata            = each.value.metadata
}

################################################################################
# Policy Set Definition (Initiative) — Org Guardrails
################################################################################

resource "azurerm_policy_set_definition" "guardrails" {
  count = var.enable_guardrails_initiative ? 1 : 0

  name                = "org-guardrails"
  policy_type         = "Custom"
  display_name        = "Organization Guardrails"
  description         = "Core guardrails for the organization landing zone"
  management_group_id = var.management_group_id

  # Allowed locations
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    reference_id         = "allowedLocations"
    parameter_values = jsonencode({
      listOfAllowedLocations = { value = var.allowed_locations }
    })
  }

  # Require a tag on resources
  dynamic "policy_definition_reference" {
    for_each = var.required_tags
    content {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
      reference_id         = "requireTag-${policy_definition_reference.value}"
      parameter_values = jsonencode({
        tagName = { value = policy_definition_reference.value }
      })
    }
  }

  # Deny public IP on network interfaces
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
    reference_id         = "denyPublicIpOnNic"
  }

  # Require HTTPS on storage accounts
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    reference_id         = "requireHttpsStorage"
  }

  # Audit VMs without managed disks
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
    reference_id         = "auditManagedDisks"
  }

  # Include custom policy definitions
  dynamic "policy_definition_reference" {
    for_each = var.policy_definitions
    content {
      policy_definition_id = azurerm_policy_definition.this[policy_definition_reference.key].id
      reference_id         = "custom-${policy_definition_reference.key}"
    }
  }
}

################################################################################
# Policy Assignment — Guardrails Initiative
################################################################################

resource "azurerm_management_group_policy_assignment" "guardrails" {
  count = var.enable_guardrails_initiative ? 1 : 0

  name                 = "org-guardrails"
  display_name         = "Organization Guardrails"
  management_group_id  = var.management_group_id
  policy_definition_id = azurerm_policy_set_definition.guardrails[0].id
  location             = var.location
  enforce              = true

  identity {
    type = "SystemAssigned"
  }
}

################################################################################
# Standalone Policy Assignments
################################################################################

resource "azurerm_management_group_policy_assignment" "standalone" {
  for_each = var.standalone_assignments

  name                 = each.key
  display_name         = each.value.display_name
  management_group_id  = coalesce(each.value.management_group_id, var.management_group_id)
  policy_definition_id = each.value.policy_definition_id
  enforce              = each.value.enforce
  location             = var.location

  dynamic "identity" {
    for_each = each.value.requires_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}
