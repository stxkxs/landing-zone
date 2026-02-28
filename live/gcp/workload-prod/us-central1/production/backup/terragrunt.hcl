include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/backup.hcl"
  merge_strategy = "deep"
}

inputs = {
  enable_backup_plan = true
}
