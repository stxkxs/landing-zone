terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/dns"
}

inputs = {
  team = "platform"
}
