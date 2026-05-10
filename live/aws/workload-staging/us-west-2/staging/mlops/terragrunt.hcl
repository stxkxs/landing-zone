include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/aws/mlops.hcl"
  merge_strategy = "deep"
}

inputs = {
  tenants = {
    default = {
      deletion_protection           = true
      point_in_time_recovery        = true
      datasets_lifecycle_ia_days    = 60
      datasets_version_expiry_days  = 730
      artifacts_lifecycle_ia_days   = 60
      artifacts_version_expiry_days = 730
      run_ttl_days                  = 180
      deprecated_version_ttl_days   = 180
    }
  }
}
