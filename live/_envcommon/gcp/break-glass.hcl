terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/break-glass"
}

inputs = {
  team = "security"
}
