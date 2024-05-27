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
  value = azurerm_virtual_network.vnet_lab.name
}

# Outputs the address space of the virtual network
output "lab_network_vnet" {
  value = azurerm_virtual_network.vnet_lab.address_space[0]
}

# Outputs the address prefixes of the subnets within the virtual network
output "lab_network_snet" {
  value = {
    "snet-0.000-jumpbox" = azurerm_subnet.snet_0000_jumpbox.address_prefixes[0],
    "snet-0.032-gateway" = azurerm_subnet.snet_0032_gateway.address_prefixes[0],
    "snet-0.064-db1"     = azurerm_subnet.snet_0064_db1.address_prefixes[0],
    "snet-0.096-db2"     = azurerm_subnet.snet_0096_db2.address_prefixes[0],
    "snet-0.128-server"  = azurerm_subnet.snet_0128_server.address_prefixes[0],
    "snet-1.000-client"  = azurerm_subnet.snet_1000_client.address_prefixes[0]
  }
}

# Outputs the public IP address of the NAT gateway
output "lab_gw_pip" {
  value = azurerm_public_ip.vnet_gw_pip.ip_address
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

# Outputs the private IP address of the VM ADDC, if it exists
output "vm_addc_private_ip" {
  description = "The private IP address of VM ADDC, if exists"
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].vm_addc_private_ip : null
}

# Outputs a list of variables to verify on 'apply' - modify in vm-addc/outputs.tf
output "addc_module_vars" {
  description = "List of vars to verify on 'apply' - modify in vm-addc/outputs.tf"
  value       = length(module.vm_addc) > 0 ? module.vm_addc[0].addc_module_vars : null
}

##### vm-sqlha.tf outputs
output "vm_sqlha_output" {
  description = "Output from the vm-sqlha module, if it exists"
  value = length(module.vm_sqlha) > 0 ? { 
    for i in range(length(module.vm_sqlha)) : 
    i => module.vm_sqlha[i].vm_sqlha 
  } : null
}
