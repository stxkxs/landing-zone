terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/cluster-bootstrap"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    cluster_name                       = "mock-gke"
    cluster_endpoint                   = "https://mock.gke.googleapis.com"
    cluster_certificate_authority_data = "bW9jaw=="
  }
}

inputs = {
  cluster_name                       = dependency.cluster.outputs.cluster_name
  cluster_endpoint                   = dependency.cluster.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.cluster.outputs.cluster_certificate_authority_data
  team                               = "platform"
}
