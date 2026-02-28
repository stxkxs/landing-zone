terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/service-quotas"
}

inputs = {
  team = "platform"
}
