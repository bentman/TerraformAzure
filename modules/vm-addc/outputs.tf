#################### OUTPUTS ####################
##### vm-addc.tf outputs
# vm-addc OUTPUTS 
output "vm_addc_public_name" {
  value = azurerm_public_ip.vm_addc_pip.fqdn
  description = "The public DNS name of addc VM"
}

output "vm_addc_public_ip" {
  value = azurerm_public_ip.vm_addc_pip.ip_address
  description = "The public IP address of addc VM"
}

output "addc_module_vars" {
  value = {
    vm_addc_hostname    = var.vm_addc_hostname
    domain_name         = var.domain_name
    domain_netbios_name = var.domain_netbios_name
  }
  description = "A map of all variables used by the submodule."
}
