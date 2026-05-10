include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/azure/druid-catalog.hcl"
  merge_strategy = "deep"
}

inputs = {
  tenant_name         = "analytics"
  postgres_sku_name   = "B_Standard_B2ms"
  postgres_storage_mb = 32768
}
