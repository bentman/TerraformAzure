#################### OUTPUTS ####################
##### main.tf outputs

# Outputs the name of the resource group
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.mylab.name
}

# Outputs the location of the resource group
output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.mylab.location
}

##### v-network.tf outputs

# Outputs the name of the virtual network
output "lab_network_vnet_name" {
  description = "The name of the virtual network"
  value       = module.v_network.lab_network_vnet_name
}

# Outputs the virtual network resource
output "lab_network_vnet" {
  description = "The virtual network resource"
  value       = module.v_network.lab_network_vnet
}

# Outputs the subnet resource
output "lab_network_snet" {
  description = "The subnet resource"
  value       = module.v_network.lab_network_snet
}

# Outputs the public IP of the gateway
output "lab_gw_pip" {
  description = "The public IP of the gateway"
  value       = module.v_network.lab_gw_pip
}

##### vm-jumpWin outputs

# Outputs the public DNS name of the Windows jumpbox VM, if it exists
output "vm_jumpwin_public_name" {
  description = "The public DNS name of Windows jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_name : null
}

# Outputs the public IP address of the Windows jumpbox VM, if it exists
output "vm_jumpwin_public_ip" {
  description = "The public IP address of Windows jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_ip : null
}

##### vm-jumpLin outputs

# Outputs the public DNS name of the Linux jumpbox VM, if it exists
output "vm_jumplin_public_name" {
  description = "The public DNS name of Linux jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_name : null
}

# Outputs the public IP address of the Linux jumpbox VM, if it exists
output "vm_jumplin_public_ip" {
  description = "The public IP address of Linux jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_ip : null
}

##### vm-addc.tf outputs

# Outputs the public DNS name of the VM ADDC, if it exists
output "vm_addc_public_name" {
  description = "The public DNS name of VM ADDC, if exists"
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].vm_addc_public_name : null
}

# Outputs the public IP address of the VM ADDC, if it exists
output "vm_addc_public_ip" {
  description = "The public IP address of VM ADDC, if exists"
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].vm_addc_public_ip : null
}

# Outputs a list of variables to verify on 'apply' - modify in vm-addc/outputs.tf
output "addc_module_vars" {
  description = "List of vars to verify on 'apply' - modify in vm-addc/outputs.tf"
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].addc_module_vars : null
}
