terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/backup"
}

inputs = {
  team = "sre"
}
