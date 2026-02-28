resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account}"
}

resource "azurerm_role_assignment" "this" {
  for_each             = toset(var.role_assignments)
  scope                = var.scope
  role_definition_name = each.value
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
