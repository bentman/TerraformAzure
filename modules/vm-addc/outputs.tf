#################### OUTPUTS ####################
##### vm-addc.tf outputs
# vm-addc OUTPUTS 
output "vm_addc_public_name" {
  value = azurerm_public_ip.vm_addc_pip.domain_name_label
}

output "vm_addc_public_ip" {
  value = azurerm_public_ip.vm_addc_pip.ip_address
}

