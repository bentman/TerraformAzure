# vm-jumpWin OUTPUTS 
output "vm_jumpwin_public_name" {
  value = azurerm_public_ip.vm_jumpwin_pip.domain_name_label
}

output "vm_jumpwin_public_ip" {
  value = azurerm_public_ip.vm_jumpwin_pip.ip_address
}

# vm-jumpLin OUTPUTS 
output "vm_jumplin_public_name" {
  value = azurerm_public_ip.vm_jumplin_pip.domain_name_label
}

output "vm_jumplin_public_ip" {
  value = azurerm_public_ip.vm_jumplin_pip.ip_address
}
