terraform {
  source = "${dirname(find_in_parent_folders("cloud.hcl"))}/..//components/azure/cluster"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vnet_id            = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock"
    private_subnet_ids = ["/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/private"]
    public_subnet_ids  = ["/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/public"]
  }
}

inputs = {
  vnet_id            = dependency.network.outputs.vnet_id
  private_subnet_ids = dependency.network.outputs.private_subnet_ids
  public_subnet_ids  = dependency.network.outputs.public_subnet_ids
  team               = "platform"
}
