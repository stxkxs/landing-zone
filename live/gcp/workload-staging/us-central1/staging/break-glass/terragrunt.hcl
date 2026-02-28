include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/break-glass.hcl"
  merge_strategy = "deep"
}

inputs = {
  trusted_members      = []
  max_session_duration = 3600
}
