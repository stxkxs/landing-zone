include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/azure/secrets.hcl"
  merge_strategy = "deep"
}

inputs = {
  # Dev/sandbox posture: short retention, no purge protection. Lets us
  # destroy-recreate cleanly. Don't use this combo for anything with real
  # data — there's no protection against accidental loss.
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}
