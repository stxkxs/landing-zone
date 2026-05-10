terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/secrets"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id     = local.account_vars.locals.subscription_id
  location            = local.region_vars.locals.region
  resource_group_name = local.env_vars.locals.environment
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    oidc_issuer_url = "https://mock.oic.prod-aks.azure.com/mock"
  }
}

inputs = {
  subscription_id     = local.subscription_id
  resource_group_name = local.resource_group_name
  location            = local.location
  oidc_issuer_url     = dependency.cluster.outputs.oidc_issuer_url
  team                = "security"
}
