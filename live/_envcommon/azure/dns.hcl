terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/dns"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id     = local.account_vars.locals.subscription_id
  resource_group_name = local.env_vars.locals.environment
}

inputs = {
  subscription_id     = local.subscription_id
  resource_group_name = local.resource_group_name
  team                = "platform"
}
