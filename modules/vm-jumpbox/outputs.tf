# vm-jumpWin OUTPUTS 
output "vm_jumpwin_public_name" {
  value = azurerm_public_ip.vm_jumpwin_pip.fqdn
}

output "vm_jumpwin_public_ip" {
  value = azurerm_public_ip.vm_jumpwin_pip.ip_address
}

# vm-jumpLin OUTPUTS 
output "vm_jumplin_public_name" {
  value = azurerm_public_ip.vm_jumplin_pip.fqdn
}

output "vm_jumplin_public_ip" {
  value = azurerm_public_ip.vm_jumplin_pip.ip_address
}
