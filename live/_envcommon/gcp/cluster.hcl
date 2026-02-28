terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/gcp/cluster"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_id         = "projects/mock/global/networks/mock"
    private_subnet_ids = ["projects/mock/regions/us-central1/subnetworks/private"]
    public_subnet_ids  = ["projects/mock/regions/us-central1/subnetworks/public"]
  }
}

inputs = {
  network_id         = dependency.network.outputs.network_id
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  public_subnet_ids  = dependency.network.outputs.public_subnet_ids
  team               = "platform"
}
