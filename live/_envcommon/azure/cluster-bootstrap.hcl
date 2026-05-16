terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/../../components/azure/cluster-bootstrap"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id = local.account_vars.locals.subscription_id
  location        = local.region_vars.locals.region
  environment     = local.env_vars.locals.environment
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    cluster_name                       = "mock-aks"
    cluster_endpoint                   = "https://mock.aks.azure.com"
    cluster_certificate_authority_data = "bW9jaw=="
  }
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vnet_name = "mock-vnet"
  }
}

inputs = {
  subscription_id                    = local.subscription_id
  location                           = local.location
  environment                        = local.environment
  cluster_name                       = dependency.cluster.outputs.cluster_name
  cluster_endpoint                   = dependency.cluster.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.cluster.outputs.cluster_certificate_authority_data
  vnet_name                          = dependency.network.outputs.vnet_name
  team                               = "platform"
}
