#################### OUTPUTS ####################

# Outputs the name of the virtual network
output "lab_network_vnet_name" {
  value = azurerm_virtual_network.azurerm_virtual_network.name
}

# Outputs the address space of the virtual network
output "lab_network_vnet" {
  value = azurerm_virtual_network.azurerm_virtual_network.address_space[0]
}

# Outputs the address prefixes of the subnets within the virtual network
output "lab_network_snet" {
  value = {
    "snet-0.000-jumpbox" = azurerm_subnet.snet_0000_jumpbox.address_prefixes[0],
    "snet-0.032-gateway" = azurerm_subnet.snet_0032_gateway.address_prefixes[0],
    "snet-0.064-db1"     = azurerm_subnet.snet_0064_db1.address_prefixes[0],
    "snet-0.096-db2"     = azurerm_subnet.snet_0096_db2.address_prefixes[0],
    "snet-0.128-server"  = azurerm_subnet.snet_0128_server.address_prefixes[0],
    "snet-1.000-client"  = azurerm_subnet.snet_1000_client.address_prefixes[0]
  }
}

# Outputs the public IP address of the NAT gateway
output "lab_gw_pip" {
  value = azurerm_public_ip.vnet_gw_pip.ip_address
}
