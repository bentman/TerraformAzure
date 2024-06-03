#################### OUTPUTS ####################
##### vm-sqlha outputs
output "vm_sqlha" {
  value = {
    for i in range(var.vm_sqlha_count) : i => {
      pip  = azurerm_public_ip.vm_sqlha_pip[i].ip_address
      name = azurerm_windows_virtual_machine.vm_sqlha[i].computer_name
    }
  }
}

##### vm-addc outputs
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

# Output the private IP address of vm-addc
output "vm_addc_private_ip" {
  description = "The private IP address of vm-addc"
  value       = azurerm_network_interface.vm_addc_nic.private_ip_address
}

# Output a map of all variables used by the submodule
output "addc_vars" {
  description = "A map of all variables used by the submodule."
  value = {
    vm_addc_hostname    = var.vm_addc_hostname
    domain_name         = var.domain_name
    domain_netbios_name = var.domain_netbios_name
  }
}