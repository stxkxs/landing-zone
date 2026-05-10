include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/azure/cost.hcl"
  merge_strategy = "deep"
}

inputs = {
  monthly_budget_limit    = 500
  budget_alert_thresholds = [80, 100]
}
