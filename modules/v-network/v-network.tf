#################### MAIN ####################
##### RESOURCES
# Create Lab vNetwork
resource "azurerm_virtual_network" "azurerm_virtual_network" {
  name                = "net-0.000-${var.lab_name}"
  address_space       = ["10.0.0.0/23"]
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Lab vSubnets
resource "azurerm_subnet" "snet_0000_jumpbox" {
  name                 = "snet-0.000-jumpbox"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.0.0/27"]
}

resource "azurerm_subnet" "snet_0032_gateway" {
  name                 = "snet-0.032-gateway"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.0.32/27"]
}

resource "azurerm_subnet" "snet_0064_db1" {
  name                 = "snet-0.064-db1"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.0.64/27"]
}

resource "azurerm_subnet" "snet_0096_db2" {
  name                 = "snet-0.096-db2"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.0.96/27"]
}

resource "azurerm_subnet" "snet_0128_server" {
  name                 = "snet-0.128-server"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.0.128/25"]
}

resource "azurerm_subnet" "snet_1000_client" {
  name                 = "snet-1.000-client"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IP address for NAT gateway
resource "azurerm_public_ip" "vnet_gw_pip" {
  name                = "net-gateway-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create NAT Gateway
resource "azurerm_nat_gateway" "vnet_gw_nat" {
  name                = "net-gateway-nat"
  location            = var.rg_location
  resource_group_name = var.rg_name
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate NAT Gateway with Public IP
resource "azurerm_nat_gateway_public_ip_association" "vnet_gw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.vnet_gw_nat.id
  public_ip_address_id = azurerm_public_ip.vnet_gw_pip.id
}

# Associate NAT Gateway with Subnets
resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_jumpbox" {
  subnet_id      = azurerm_subnet.snet_0000_jumpbox.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_gateway" {
  subnet_id      = azurerm_subnet.snet_0032_gateway.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_db1" {
  subnet_id      = azurerm_subnet.snet_0064_db1.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_db2" {
  subnet_id      = azurerm_subnet.snet_0096_db2.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_server" {
  subnet_id      = azurerm_subnet.snet_0128_server.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vnet_gw_snet_assoc_client" {
  subnet_id      = azurerm_subnet.snet_1000_client.id
  nat_gateway_id = azurerm_nat_gateway.vnet_gw_nat.id
}
