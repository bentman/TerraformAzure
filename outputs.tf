#################### OUTPUTS ####################
##### main.tf outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.mylab.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.mylab.location
}

##### v-network.tf outputs
output "lab_network_vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet_lab.name
}

output "lab_network_vnet" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.vnet_lab.address_space[0]
}

output "lab_network_snet" {
  description = "Address prefixes of subnets within virtual network"
  value = {
    "snet-0.000-jumpbox" = azurerm_subnet.snet_0000_jumpbox.address_prefixes[0],
    "snet-0.032-gateway" = azurerm_subnet.snet_0032_gateway.address_prefixes[0],
    "snet-0.064-db1"     = azurerm_subnet.snet_0064_db1.address_prefixes[0],
    "snet-0.096-db2"     = azurerm_subnet.snet_0096_db2.address_prefixes[0],
    "snet-0.128-server"  = azurerm_subnet.snet_0128_server.address_prefixes[0],
    "snet-1.000-client"  = azurerm_subnet.snet_1000_client.address_prefixes[0]
  }
}

output "lab_gw_pip" {
  description = "Public IP address of the NAT gateway"
  value       = azurerm_public_ip.vnet_gw_pip.ip_address
}

##### vm-jumpWin outputs
output "vm_jumpwin_public_name" {
  description = "Public DNS name of Windows jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_name : null
}

output "vm_jumpwin_public_ip" {
  description = "Public IP address of Windows jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumpwin_public_ip : null
}

##### vm-jumpLin outputs
output "vm_jumplin_public_name" {
  description = "Public DNS name of Linux jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_name : null
}

output "vm_jumplin_public_ip" {
  description = "Public IP address of Linux jumpbox VM, if exists - 'null' if not"
  value       = length(module.vm_jumpbox) > 0 ? module.vm_jumpbox[0].vm_jumplin_public_ip : null
}

##### sql-ha outputs
# Outputs a list of variables to verify on 'apply' - modify in vm-addc/outputs.tf
output "addc_vars" {
  description = "List of vars to verify on 'apply' - modify in vm-addc/outputs.tf"
  value       = length(module.sql_ha) > 0 ? module.sql_ha[0].addc_vars : null
}

# vm-sqlha outputs
output "vm_sqlha_servers" {
  description = "Output from the vm-sqlha module, if it exists"
  value = length(module.sql_ha) > 0 ? {
    for i in range(length(module.sql_ha)) :
    i => module.sql_ha[i].vm_sqlha
  } : null
}

##### addc outputs
# Outputs the public DNS name of the VM ADDC, if it exists
output "vm_addc_public_name" {
  description = "Public DNS name of VM ADDC, if exists"
  value       = length(module.sql_ha) > 0 ? module.sql_ha[0].vm_addc_public_name : null
}

# Outputs the public IP address of the VM ADDC, if it exists
output "vm_addc_public_ip" {
  description = "Public IP address of VM ADDC, if exists"
  value       = length(module.sql_ha) > 0 ? module.sql_ha[0].vm_addc_public_ip : null
}

# Outputs the private IP address of the VM ADDC, if it exists
output "vm_addc_private_ip" {
  description = "Private IP address of VM ADDC, if exists"
  value       = length(module.sql_ha) > 0 ? module.sql_ha[0].vm_addc_private_ip : null
}

##### dc1 outputs
# Outputs the public DNS name of the VM dc1, if it exists
output "vm_dc1_public_name" {
  description = "Public DNS name of VM dc1, if exists"
  value       = length(module.vm_dc1) > 0 ? module.vm_dc1[0].vm_dc1_public_name : null
}

# Outputs the public IP address of the VM dc1, if it exists
output "vm_dc1_public_ip" {
  description = "Public IP address of VM dc1, if exists"
  value       = length(module.vm_dc1) > 0 ? module.vm_dc1[0].vm_dc1_public_ip : null
}

# Outputs the private IP address of the VM dc1, if it exists
output "vm_dc1_private_ip" {
  description = "Private IP address of VM dc1, if exists"
  value       = length(module.vm_dc1) > 0 ? module.vm_dc1[0].vm_dc1_private_ip : null
}

# Outputs a list of variables to verify on 'apply' - modify in vm-dc1/outputs.tf
output "dc1_module_vars" {
  description = "List of vars to verify on 'apply' - modify in vm-dc1/outputs.tf"
  value       = length(module.vm_dc1) > 0 ? module.vm_dc1[0].dc1_module_vars : null
}
