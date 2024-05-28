#################### OUTPUTS ####################
##### vm-dc1.tf outputs

output "vm_dc1_public_name" {
  description = "Public DNS name of vm-dc1"
  value       = azurerm_public_ip.vm_dc1_pip.fqdn
}

output "vm_dc1_public_ip" {
  description = "Public IP address of vm-dc1"
  value       = azurerm_public_ip.vm_dc1_pip.ip_address
}

output "vm_dc1_private_ip" {
  description = "Private IP address of vm-dc1"
  value       = azurerm_network_interface.vm_dc1_nic.private_ip_address
}

output "addc_module_vars" {
  description = "Map of all variables used by submodule."
  value = {
    vm_dc1_hostname     = var.vm_dc1_hostname
    domain_name         = var.dc1_domain_name
    domain_netbios_name = var.dc1_domain_netbios_name
  }
}
