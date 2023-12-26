output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_name" {
  value = azurerm_subnet.jumpbox_subnet.name
}

output "vm-jumpwin_name" {
  value = azurerm_virtual_machine.vm-jumpwin.name
}

output "vm-jumpwin_id" {
  value = azurerm_virtual_machine.vm-jumpwin.id
}

output "vm-jumpwin_public_ip" {
  value = azurerm_public_ip.vm-jumpwin_pip.ip_address
}

output "vm-jumplin_name" {
  value = azurerm_virtual_machine.vm-jumplin.name
}

output "vm-jumplin_id" {
  value = azurerm_virtual_machine.vm-jumplin.id
}

output "vm-jumplin_public_ip" {
  value = azurerm_public_ip.vm-jumplin_pip.ip_address
}
