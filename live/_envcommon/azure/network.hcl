terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/../../components/azure/network"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id     = local.account_vars.locals.subscription_id
  location            = local.region_vars.locals.region
  environment         = local.env_vars.locals.environment
  resource_group_name = local.env_vars.locals.environment
}

inputs = {
  subscription_id     = local.subscription_id
  resource_group_name = local.resource_group_name
  location            = local.location
  environment         = local.environment
  cluster_name        = "aks"
  team                = "platform"
}
