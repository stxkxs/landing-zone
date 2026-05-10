terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/cluster-addons"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    cluster_name           = "mock-gke"
    workload_identity_pool = "mock-project.svc.id.goog"
  }
}

inputs = {
  cluster_name           = dependency.cluster.outputs.cluster_name
  workload_identity_pool = dependency.cluster.outputs.workload_identity_pool
  team                   = "platform"
}
