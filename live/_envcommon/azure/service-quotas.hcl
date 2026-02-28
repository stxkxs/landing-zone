terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/service-quotas"
}

inputs = {
  team = "platform"
}
