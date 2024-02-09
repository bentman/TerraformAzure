output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.lab_network.name
}

output "subnet_name" {
  value = azurerm_subnet.jumpbox_subnet.name
}

output "vm_jumpwin_name" {
  value = azurerm_windows_virtual_machine.vm_jumpwin.name
}

output "vm_jumpwin_id" {
  value = azurerm_windows_virtual_machine.vm_jumpwin.id
}

output "vm_jumpwin_public_ip" {
  value = azurerm_public_ip.vm_jumpwin_pip.ip_address
}

output "vm_jumplin_name" {
  value = azurerm_linux_virtual_machine.vm_jumplin.name
}

output "vm_jumplin_id" {
  value = azurerm_linux_virtual_machine.vm_jumplin.id
}

output "vm_jumplin_public_ip" {
  value = azurerm_public_ip.vm_jumplin_pip.ip_address
}

output "vm_sql_name" {
  value = azurerm_linux_virtual_machine.vm_jumplin.name
}

/*
### SQL Server Outputs
output "vm_sql_id" {
  value = azurerm_linux_virtual_machine.vm_jumplin.id
}

output "vm_sql_public_ip" {
  value = azurerm_public_ip.vm_jumplin_pip.ip_address
}

output "vm_sql_password" {
  value     = local.sqladmin_password
  sensitive = true
}
*/
