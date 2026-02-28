terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/network"
}

inputs = {
  cluster_name = "aks"
  team         = "platform"
}
