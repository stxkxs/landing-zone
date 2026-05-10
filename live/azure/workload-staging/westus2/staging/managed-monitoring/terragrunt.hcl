include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/azure/managed-monitoring.hcl"
  merge_strategy = "deep"
}

inputs = {
  grafana_sku                     = "Standard"
  grafana_zone_redundancy_enabled = false
}
