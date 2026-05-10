terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/observability"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    cluster_name = "mock-gke"
  }
}

inputs = {
  cluster_name = dependency.cluster.outputs.cluster_name
  team         = "sre"
}
