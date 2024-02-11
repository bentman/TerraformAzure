############################ NETWORK ############################

output "az_resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "lab_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_0000_jumpbox" {
  value = azurerm_subnet.subnet_0000_jumpbox.address_prefixes
}

output "subnet_0032_gateway" {
  value = azurerm_subnet.subnet_0032_gateway.address_prefixes
}

output "subnet_0064_mgmnt" {
  value = azurerm_subnet.subnet_0064_mgmnt.address_prefixes
}

output "subnet_0128_server" {
  value = azurerm_subnet.subnet_0128_server.address_prefixes
}

output "subnet_1000_client" {
  value = azurerm_subnet.subnet_1000_client.address_prefixes
}

############################ JUMPBOX ############################

output "vm_jumpwin_hostname" {
  value = azurerm_windows_virtual_machine.vm_jumpwin.computer_name
}

output "vm_jumpwin_public_ip" {
  value = azurerm_public_ip.vm_jumpwin_pip.ip_address
}

output "vm_jumplin_hostname" {
  value = azurerm_linux_virtual_machine.vm_jumplin.computer_name
}

output "vm_jumplin_public_ip" {
  value = azurerm_public_ip.vm_jumplin_pip.ip_address
}

############################ SERVERS ############################
