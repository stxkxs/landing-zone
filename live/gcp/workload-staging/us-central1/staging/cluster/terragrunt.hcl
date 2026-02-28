include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/cluster.hcl"
  merge_strategy = "deep"
}

inputs = {
  cluster_endpoint_public_access = false
  system_node_min_size           = 2
  system_node_max_size           = 6
}
