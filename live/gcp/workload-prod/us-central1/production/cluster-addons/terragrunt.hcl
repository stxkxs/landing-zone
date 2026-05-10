include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/cluster-addons.hcl"
  merge_strategy = "deep"
}

inputs = {}
