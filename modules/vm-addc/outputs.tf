#################### OUTPUTS ####################
##### vm-addc.tf outputs

# Output the public DNS name of vm-addc
output "vm_addc_public_name" {
  description = "The public DNS name of vm-addc"
  value       = azurerm_public_ip.vm_addc_pip.fqdn
}

# Output the public IP address of vm-addc
output "vm_addc_public_ip" {
  description = "The public IP address of vm-addc"
  value       = azurerm_public_ip.vm_addc_pip.ip_address
}

# Output a map of all variables used by the submodule
output "addc_module_vars" {
  description = "A map of all variables used by the submodule."
  value = {
    vm_addc_hostname    = var.vm_addc_hostname
    domain_name         = var.domain_name
    domain_netbios_name = var.domain_netbios_name
  }
}
