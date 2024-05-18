#################### MAIN ####################
##### RESOURCES
# Create Lab Resource Group
resource "azurerm_resource_group" "mylab" {
  name     = "rg-${var.lab_name}-${var.rg_location}"
  location = var.rg_location
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

##### MODULES
# v-network.tf
module "v_network" {
  source      = "./modules/v-network"
  lab_name    = var.lab_name
  rg_location = azurerm_resource_group.mylab.location
  rg_name     = azurerm_resource_group.mylab.name
  tags        = var.tags
  depends_on  = [azurerm_resource_group.mylab]
}

# vm-jumpbox.tf
module "vm_jumpbox" {
  source              = "./modules/vm-jumpbox"
  lab_name            = var.lab_name
  rg_location         = azurerm_resource_group.mylab.location
  rg_name             = azurerm_resource_group.mylab.name
  vm_snet_id          = data.azurerm_subnet.snet_0000_jumpbox.id
  vm_jumpwin_hostname = var.vm_jumpwin_hostname
  vm_jumplin_hostname = var.vm_jumplin_hostname
  vm_size             = var.vm_size
  vm_localadmin_user  = var.vm_localadmin_user
  vm_localadmin_pswd  = var.vm_localadmin_pswd
  vm_shutdown_hhmm    = var.vm_shutdown_hhmm
  vm_shutdown_tz      = var.vm_shutdown_tz
  tags                = var.tags
  depends_on          = [module.v_network]
}

# vm-addc.tf

# vm-sqlha.tf

