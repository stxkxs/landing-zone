locals {
  labels = {
    component = "org-policy"
    team      = var.team
  }

  # Default boolean constraints to enforce at the org level
  default_boolean_constraints = {
    "compute.disableSerialPortAccess"      = true
    "compute.requireOsLogin"               = true
    "compute.disableNestedVirtualization"  = true
    "iam.disableServiceAccountKeyCreation" = true
    "storage.uniformBucketLevelAccess"     = true
  }

  boolean_constraints = merge(local.default_boolean_constraints, var.boolean_constraints)
}

################################################################################
# Boolean Organization Policy Constraints
################################################################################

resource "google_org_policy_policy" "boolean" {
  for_each = local.boolean_constraints

  name   = "organizations/${var.org_id}/policies/${each.key}"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = each.value ? "TRUE" : "FALSE"
    }
  }
}

################################################################################
# List Organization Policy Constraints
################################################################################

resource "google_org_policy_policy" "list" {
  for_each = var.list_constraints

  name   = "organizations/${var.org_id}/policies/${each.key}"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      dynamic "values" {
        for_each = length(each.value.allowed_values) > 0 ? [1] : []
        content {
          allowed_values = each.value.allowed_values
        }
      }

      dynamic "values" {
        for_each = length(each.value.denied_values) > 0 ? [1] : []
        content {
          denied_values = each.value.denied_values
        }
      }
    }
  }
}
