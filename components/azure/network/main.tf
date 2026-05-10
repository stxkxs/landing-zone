locals {
  vnet_cidr    = "10.0.0.0/16"
  cluster_name = "${var.environment}-${var.cluster_name}"

  tags = {
    Component = "network"
    Team      = var.team
  }
}

################################################################################
# Resource Group (data source — assumes pre-created by bootstrap)
################################################################################

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

################################################################################
# Virtual Network
################################################################################

resource "azurerm_virtual_network" "this" {
  name                = "${var.environment}-vnet"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  address_space       = [local.vnet_cidr]

  tags = local.tags
}

################################################################################
# Subnets
################################################################################

resource "azurerm_subnet" "private" {
  count = 3

  name                 = "${var.environment}-private-${count.index}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(local.vnet_cidr, 8, count.index + 10)]
}

resource "azurerm_subnet" "public" {
  count = 3

  name                 = "${var.environment}-public-${count.index}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(local.vnet_cidr, 8, count.index)]
}

################################################################################
# NAT Gateway
################################################################################

resource "azurerm_public_ip" "nat" {
  count = var.nat_gateways

  name                = "${var.environment}-nat-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.nat_gateways

  name                    = "${var.environment}-nat-${count.index}"
  resource_group_name     = data.azurerm_resource_group.this.name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.nat_gateways

  nat_gateway_id       = azurerm_nat_gateway.this[count.index].id
  public_ip_address_id = azurerm_public_ip.nat[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  count = 3

  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.this[count.index % var.nat_gateways].id
}

################################################################################
# Network Security Groups
################################################################################

resource "azurerm_network_security_group" "private" {
  name                = "${var.environment}-private-nsg"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_network_security_group" "public" {
  name                = "${var.environment}-public-nsg"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count = 3

  subnet_id                 = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  count = 3

  subnet_id                 = azurerm_subnet.public[count.index].id
  network_security_group_id = azurerm_network_security_group.public.id
}

################################################################################
# NSG Flow Logs
################################################################################

resource "azurerm_network_watcher" "this" {
  count = var.enable_flow_logs ? 1 : 0

  name                = "${var.environment}-network-watcher"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  tags = local.tags
}

resource "azurerm_storage_account" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name                     = "${replace(var.environment, "-", "")}flowlogs"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_network_watcher_flow_log" "private" {
  count = var.enable_flow_logs ? 1 : 0

  name                 = "${var.environment}-private-nsg-flow-log"
  network_watcher_name = azurerm_network_watcher.this[0].name
  resource_group_name  = data.azurerm_resource_group.this.name

  network_security_group_id = azurerm_network_security_group.private.id
  storage_account_id        = azurerm_storage_account.flow_logs[0].id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 30
  }

  tags = local.tags
}

resource "azurerm_network_watcher_flow_log" "public" {
  count = var.enable_flow_logs ? 1 : 0

  name                 = "${var.environment}-public-nsg-flow-log"
  network_watcher_name = azurerm_network_watcher.this[0].name
  resource_group_name  = data.azurerm_resource_group.this.name

  network_security_group_id = azurerm_network_security_group.public.id
  storage_account_id        = azurerm_storage_account.flow_logs[0].id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 30
  }

  tags = local.tags
}
