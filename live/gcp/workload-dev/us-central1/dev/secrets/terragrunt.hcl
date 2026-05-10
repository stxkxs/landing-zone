include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/secrets.hcl"
  merge_strategy = "deep"
}

inputs = {
  kms_key_rotation_days = 90
}
