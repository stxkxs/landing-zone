terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/secrets"
}

dependency "cluster" {
  config_path = "../cluster"
  mock_outputs = {
    oidc_issuer_url = "https://mock.oic.prod-aks.azure.com/mock"
  }
}

inputs = {
  oidc_issuer_url = dependency.cluster.outputs.oidc_issuer_url
  team            = "security"
}
