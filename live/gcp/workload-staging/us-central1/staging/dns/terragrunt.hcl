include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("cloud.hcl"))}/../_envcommon/gcp/dns.hcl"
  merge_strategy = "deep"
}

inputs = {
  domain_name        = "staging.example.com"
  create_managed_zone = true
  enable_dnssec      = false
}
