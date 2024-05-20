#################### OUTPUTS ####################
##### main.tf outputs
output "resource_group_name" {
  value = azurerm_resource_group.mylab.name
}
output "resource_group_location" {
  value = azurerm_resource_group.mylab.location
}

##### v-network.tf outputs
output "lab_network_vnet_name" {
  value = module.v_network.lab_network_vnet_name
}

output "lab_network_vnet" {
  value = module.v_network.lab_network_vnet
}

output "lab_network_snet" {
  value = module.v_network.lab_network_snet
}

output "lab_gw_pip" {
  value = module.v_network.lab_gw_pip
}

# vm-jumpWin OUTPUTS 
output "vm_jumpwin_public_name" {
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_name : null
  description = "The public DNS name of windows jumpbox VM, if exists - 'null' if not"
}

output "vm_jumpwin_public_ip" {
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_ip : null
  description = "The public IP address of windows jumpbox VM, if exists - 'null' if not"
}
# vm-jumpLin OUTPUTS 
output "vm_jumplin_public_name" {
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_name : null
  description = "The public DNS name of Linux jumpbox VM, if exists - 'null' if not"
}

output "vm_jumplin_public_ip" {
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_ip : null
  description = "The public IP address of Linux jumpbox VM, if exists - 'null' if not"
}

##### vm-addc.tf outputs
output "vm_addc_public_name" {
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].vm_addc_public_name : null
  description = "The public DNS name of addc VM, if exists"
}

output "vm_addc_public_ip" {
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].vm_addc_public_ip : null
  description = "The public IP address of addc VM, if exists"
}

output "addc_module_vars" {
  value = module.vm_addc[0].addc_module_vars
}
