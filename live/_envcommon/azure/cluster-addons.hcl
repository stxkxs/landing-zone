terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/cluster-addons"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    cluster_name    = "mock-aks"
    oidc_issuer_url = "https://mock.oic.prod-aks.azure.com/mock"
  }
}

inputs = {
  cluster_name    = dependency.cluster.outputs.cluster_name
  oidc_issuer_url = dependency.cluster.outputs.oidc_issuer_url
  team            = "platform"
}
