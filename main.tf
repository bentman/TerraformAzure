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

# vm-jumpbox.tf
variable "module_vm_jumpbox_enable" {
  description = "A boolean flag to enable or disable the vm-jumpbox.tf module"
  type        = bool
  default     = false // true -or- false 
  //caution: 'terraform plan' produces 'changed state' after toggle
  //         if exist, resources will be destroyed on next 'apply'
  //         false = '# to destroy' | true = '# to add ... # to destroy'
}

module "vm_jumpbox" {
  # Module for deploying jumpbox vm's in their own subnet
  count               = var.module_vm_jumpbox_enable ? 1 : 0
  source              = "./modules/vm-jumpbox"
  lab_name            = var.lab_name
  rg_name             = azurerm_resource_group.mylab.name
  rg_location         = azurerm_resource_group.mylab.location
  vm_snet_id          = azurerm_subnet.snet_0000_jumpbox.id
  vm_jumpwin_hostname = var.vm_jumpwin_hostname
  vm_jumplin_hostname = var.vm_jumplin_hostname
  vm_size             = var.vm_size
  vm_localadmin_user  = var.vm_localadmin_user
  vm_localadmin_pswd  = var.vm_localadmin_pswd
  vm_shutdown_hhmm    = var.vm_shutdown_hhmm
  vm_shutdown_tz      = var.vm_shutdown_tz
  tags                = var.tags
  depends_on = [
    data.azurerm_subnet.snet_0000_jumpbox
  ]
}

##############################################################
########## Cannot be applied with vm-addc module!!! ##########
variable "module_sql_ha_enable" {
  description = "A boolean flag to enable or disable the ./modules/sql-ha module"
  type        = bool
  default     = false // true -or- false 
  //caution: 'terraform plan' produces 'changed state' after toggle
  //         if exist, resources will be destroyed on next 'apply'
  //         false = '# to destroy' | true = '# to add ... # to destroy'
}

module "sql_ha" {
  # Module for deploying SQL High Availability VMs
  count                    = var.module_sql_ha_enable ? 1 : 0
  source                   = "./modules/sql-ha"
  lab_name                 = var.lab_name
  rg_name                  = azurerm_resource_group.mylab.name
  rg_location              = azurerm_resource_group.mylab.location
  snet_0128_server_id      = data.azurerm_subnet.snet_0128_server.id
  snet_0064_db1_id         = data.azurerm_subnet.snet_0064_db1.id
  snet_0096_db2_id         = data.azurerm_subnet.snet_0096_db2.id
  snet_0064_db1_prefixes   = data.azurerm_subnet.snet_0064_db1.address_prefixes
  snet_0096_db2_prefixes   = data.azurerm_subnet.snet_0096_db2.address_prefixes
  domain_name              = var.domain_name
  domain_netbios_name      = var.domain_netbios_name
  safemode_admin_pswd      = var.safemode_admin_pswd
  vm_shutdown_tz           = var.vm_shutdown_tz
  vm_addc_hostname         = var.vm_addc_hostname
  vm_addc_size             = var.vm_addc_size
  vm_addc_localadmin_user  = var.domain_admin_user //NOTE: becomes domain admin after dcpromo
  vm_addc_localadmin_pswd  = var.domain_admin_pswd //NOTE: becomes domain admin after dcpromo
  vm_addc_public_ip        = module.vm_addc[0].vm_addc_public_ip
  vm_addc_private_ip       = module.vm_addc[0].vm_addc_private_ip
  vm_sqlha_hostname        = var.vm_sqlha_hostname
  vm_sqlha_size            = var.vm_sqlha_size
  vm_sqlha_localadmin_user = var.vm_localadmin_user
  vm_sqlha_localadmin_pswd = var.vm_localadmin_pswd
  vm_sqlha_shutdown_hhmm   = var.vm_shutdown_hhmm
  sql_sysadmin_user        = var.sql_sysadmin_user
  sql_sysadmin_pswd        = var.sql_sysadmin_pswd
  sql_svc_acct_user        = var.sql_svc_acct_user
  sql_svc_acct_pswd        = var.sql_svc_acct_pswd
  sqlaag_name              = var.sqlaag_name
  sqlcluster_name          = var.sqlcluster_name
  tags                     = var.tags
  depends_on = [
    azurerm_subnet.snet_0128_server,
    azurerm_subnet.snet_0064_db1,
    azurerm_subnet.snet_0096_db2,
  ]
}

##############################################################
########## Cannot be applied with sql_ha module!!!! ##########
# vm-addc.tf
variable "module_addc_enable" {
  description = "A boolean flag to enable or disable the ./modules/vm-addc module"
  type        = bool
  default     = false // true -or- false 
  //caution: 'terraform plan' produces 'changed state' after toggle
  //         if exist, resources will be destroyed on next 'apply'
  //         false = '# to destroy' | true = '# to add ... # to destroy'
}

module "vm_addc" {
  # Module for deploying first Active Directory Domain Controller in Forest
  count                 = var.module_addc_enable ? 1 : 0
  source                = "./modules/vm-addc"
  lab_name              = var.lab_name
  rg_name               = azurerm_resource_group.mylab.name
  rg_location           = azurerm_resource_group.mylab.location
  vm_server_snet_id     = azurerm_subnet.snet_0128_server.id
  vm_addc_hostname      = var.vm_addc_hostname
  vm_addc_size          = var.vm_addc_size
  domain_name           = var.domain_name
  domain_netbios_name   = var.domain_netbios_name
  vm_localadmin_user    = var.domain_admin_user //NOTE: becomes domain admin after dcpromo
  vm_localadmin_pswd    = var.domain_admin_pswd //NOTE: becomes domain admin after dcpromo
  safemode_admin_pswd   = var.safemode_admin_pswd
  sql_svc_acct_user     = var.sql_svc_acct_user
  sql_svc_acct_pswd     = var.sql_svc_acct_pswd
  vm_addc_shutdown_hhmm = var.vm_shutdown_hhmm
  vm_addc_shutdown_tz   = var.vm_shutdown_tz
  tags                  = var.tags
  depends_on = [
    data.azurerm_subnet.snet_0128_server
  ]
}
