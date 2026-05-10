include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/aws/gateway.hcl"
  merge_strategy = "deep"
}

inputs = {
  tenants = {
    default = {
      deletion_protection      = true
      bot_control_enabled      = true
      logging_level            = "INFO"
      waf_rate_limit           = 5000
      cognito_password_min     = 12
      cognito_access_token_hrs = 4
      throttle_rate_limit      = 500
      throttle_burst_limit     = 1000
      throttle_quota_per_month = 5000000
    }
  }
}
