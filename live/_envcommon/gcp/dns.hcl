terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/dns"
}

inputs = {
  team = "platform"
}
