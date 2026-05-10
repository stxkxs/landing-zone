terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/break-glass"
}

inputs = {
  team = "security"
}
