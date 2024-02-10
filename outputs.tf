output "az_resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "lab_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_0000-jumpbox" {
  value = azurerm_subnet.subnet_0000-jumpbox.name
}

output "subnet_0032-gateway" {
  value = azurerm_subnet.subnet_0032-gateway.name
}

output "subnet_0064-mgmnt" {
  value = azurerm_subnet.subnet_0064-mgmnt.name
}

output "subnet_0128-server" {
  value = azurerm_subnet.subnet_0128-server.name
}

output "subnet_1000-client" {
  value = azurerm_subnet.subnet_1000-client
}

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
