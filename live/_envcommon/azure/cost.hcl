terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/cost"
}

inputs = {
  team = "finops"
}
