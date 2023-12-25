output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_name" {
  value = azurerm_subnet.jumpbox_subnet.name
}

output "windows_vm_name" {
  value = azurerm_virtual_machine.windows_vm.name
}

output "windows_vm_id" {
  value = azurerm_virtual_machine.windows_vm.id
}

output "windows_vm_public_ip" {
  value = azurerm_public_ip.windows_vm_pip.ip_address
}

output "linux_vm_name" {
  value = azurerm_virtual_machine.linux_vm.name
}

output "linux_vm_id" {
  value = azurerm_virtual_machine.linux_vm.id
}

output "linux_vm_public_ip" {
  value = azurerm_public_ip.linux_vm_pip.ip_address
}
