include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/aws/governance.hcl"
  merge_strategy = "deep"
}

inputs = {
  tenants = {
    default = {
      deletion_protection    = true
      object_lock_enabled    = false
      point_in_time_recovery = true
      lifecycle_ia_days      = 60
      cost_ttl_days          = 180
    }
  }
}
