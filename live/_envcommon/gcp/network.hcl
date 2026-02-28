terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/network"
}

inputs = {
  cluster_name = "gke"
  team         = "platform"
}
