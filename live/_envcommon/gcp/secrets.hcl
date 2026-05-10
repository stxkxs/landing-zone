terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/secrets"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    workload_identity_pool = "mock-project.svc.id.goog"
  }
}

inputs = {
  workload_identity_pool = dependency.cluster.outputs.workload_identity_pool
  team                   = "security"
}
