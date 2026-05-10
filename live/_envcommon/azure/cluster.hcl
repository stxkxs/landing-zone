terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/cluster"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id     = local.account_vars.locals.subscription_id
  tenant_id           = local.account_vars.locals.tenant_id
  location            = local.region_vars.locals.region
  resource_group_name = local.env_vars.locals.environment
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vnet_id            = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock"
    private_subnet_ids = ["/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/private"]
    public_subnet_ids  = ["/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/public"]
  }
}

inputs = {
  subscription_id     = local.subscription_id
  tenant_id           = local.tenant_id
  location            = local.location
  resource_group_name = local.resource_group_name
  vnet_id             = dependency.network.outputs.vnet_id
  private_subnet_ids  = dependency.network.outputs.private_subnet_ids
  public_subnet_ids   = dependency.network.outputs.public_subnet_ids
  team                = "platform"
}
