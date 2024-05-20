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
variable "module_vm_jumpbox_enable" {
  description = "A boolean flag to enable or disable the vm-jumpbox.tf module"
  type        = bool
  default     = false // true -or- false 
  //caution: even 'terraform plan' produces 'changed state' after toggle
  //         if exist, resources will be destroyed on next 'apply'
  //         false = '# to destroy' | true = '# to add ... # to destroy'
}

module "vm_jumpbox" {
  count               = var.module_vm_jumpbox_enable ? 1 : 0
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
  depends_on          = [module.v_network, data.azurerm_subnet.snet_0000_jumpbox]
}

# vm-addc.tf
variable "module_vm_addc_enable" {
  description = "A boolean flag to enable or disable the vm-addc.tf module"
  type        = bool
  default     = true // true -or- false 
  //caution: even 'terraform plan' produces 'changed state' after toggle
  //         if exist, resources will be destroyed on next 'apply'
  //         false = '# to destroy' | true = '# to add ... # to destroy'
}

module "vm_addc" {
  count                 = var.module_vm_addc_enable ? 1 : 0
  source                = "./modules/vm-addc"
  lab_name              = var.lab_name
  rg_location           = azurerm_resource_group.mylab.location
  rg_name               = azurerm_resource_group.mylab.name
  vm_server_snet_id     = data.azurerm_subnet.snet_0128_server.id
  vm_addc_hostname      = var.vm_addc_hostname
  vm_addc_size          = var.vm_addc_size
  domain_name           = var.domain_name
  domain_netbios_name   = var.domain_netbios_name
  vm_localadmin_user    = var.domain_admin_user //NOTE: becomes domain admin after dcpromo
  vm_localadmin_pswd    = var.domain_admin_pswd //NOTE: becomes domain admin after dcpromo
  safemode_admin_pswd   = var.safemode_admin_pswd
  vm_addc_shutdown_hhmm = var.vm_shutdown_hhmm
  vm_addc_shutdown_tz   = var.vm_shutdown_tz
  tags                  = var.tags
  depends_on            = [module.v_network, data.azurerm_subnet.snet_0128_server]
}

# vm-sqlha.tf
