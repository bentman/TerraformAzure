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
