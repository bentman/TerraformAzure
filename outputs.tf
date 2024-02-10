output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_name" {
  value = azurerm_subnet.jumpbox_subnet.name
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

### SQL Server Outputs
output "vm_sql_hostname" {
  value = azurerm_windows_virtual_machine.vm_sql.computer_name
}

output "vm_sql_public_ip" {
  value = azurerm_network_interface.vm_sql_nic.private_ip_address
}

output "vm_sql_password" {
  value     = local.generated_password
  sensitive = true
}
