#################### VARIABLES ####################
########## SECRETS VARIABLES 
#####  Declare confidential variables here
#####  Store secret values in *.tfvars file
#####  Check .gitignore in repo for details
########## SECRETS VARIABLES 

variable "arm_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "arm_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "arm_client_id" {
  description = "Azure Client ID (Service Principal ID)"
  type        = string
}

variable "arm_client_secret" {
  description = "Azure Client Secret (Service Principal Secret)"
  type        = string
  sensitive   = true
}

variable "vm_localadmin_user" {
  description = "VM local admin username"
  type        = string
  default     = "localadmin"
  sensitive   = true
}

variable "vm_localadmin_pswd" {
  description = "VM local admin password"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

##### MODULE VARIABLES
# caution: 'terraform plan' produces 'changed state' after toggle
#          if exist, resources may be destroyed on next 'apply'
variable "enable_module_vm_jumpbox" {
  description = "Boolean flag to enable or disable the ./modules/vm-jumpbox"
  type        = bool
  default     = false // true -or- false 
}

variable "enable_module_sql_ha" {
  description = "Boolean flag to enable or disable the ./modules/sql-ha"
  type        = bool
  default     = false // true -or- false 
}

variable "enable_module_dc1" {
  description = "Boolean flag to enable or disable the ./modules/vm-addc"
  type        = bool
  default     = false // true -or- false 
}

##### RESOURCE VARIABLES
variable "lab_name" {
  description = "lab name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  type        = string
  default     = "mylab"
}

variable "rg_location" {
  description = "Azure region for lab"
  type        = string
  default     = "westus"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}

########## vm-jumpBox VARIABLES
# vm-jumpLin Hostname
variable "vm_jumplin_hostname" {
  description = "Computer name for the Linux VM jumpbox"
  type        = string
  default     = "vm-jumplin008" // fail if not unique in public DNS
}

# vm-jumpWin Hostname
variable "vm_jumpwin_hostname" {
  description = "Computer name for the Windows VM jumpbox"
  type        = string
  default     = "vm-jumpwin007" // fail if not unique in public DNS
}

# vm common Variables
variable "vm_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3" // 2 x vCPU + 8GB RAM
}

variable "vm_shutdown_hhmm" {
  description = "Time for VM Shutdown (HHMM)"
  type        = string
  default     = "0000" // midnight ;-)
}

variable "vm_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

########## vm-addc VARIABLES
variable "vm_addc_hostname" {
  description = "Hostname for the domain controller"
  type        = string
  default     = "vm-addc" // fail if not unique in public DNS
}

variable "vm_addc_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_addc_shutdown_hhmm" {
  description = "Time for VM Shutdown (HHMM)"
  type        = string
  default     = "0015" // midnight ;-)
}

########## addc VARIABLES
variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "mylab.mytenant.onmicrosoft.lan"
}

variable "domain_netbios_name" {
  description = "Domain NetBIOS name"
  type        = string
  default     = "MYLAB"
}

variable "domain_admin_user" {
  description = "Domain admin username"
  type        = string
  default     = "domainadmin"
  sensitive   = true
}

variable "domain_admin_pswd" {
  description = "Domain admin password"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

variable "safemode_admin_pswd" {
  description = "Domain Safe Mode password"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

########## vm-sqlha VARIABLES
variable "sqlaag_name" {
  description = "Name of the SQL AG (Availability Group)"
  type        = string
  default     = "sqlhaaoaag"
}

variable "sqlcluster_name" {
  description = "Name of the SQL cluster"
  type        = string
  default     = "sqlcluster"
}

variable "vm_sqlha_hostname" {
  description = "Computername for vm-sqlha appended by vm_sqlha_count #"
  type        = string
  default     = "vm-sqlha" // maximum of 14 char // fail if not unique in public DNS
}

variable "vm_sqlha_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_sqlha_shutdown_hhmm" {
  description = "Time for VM Shutdown (HHMM)"
  type        = string
  default     = "0000" // midnight ;-)
}

variable "vm_sqlha_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

variable "sql_sysadmin_user" {
  description = "SQL sysadmin username"
  type        = string
  default     = "sqladmin"
}

variable "sql_sysadmin_pswd" {
  description = "SQL sysadmin password"
  type        = string
  default     = "'P@ssw0rd!234'"
  sensitive   = true
}

variable "sql_svc_acct_user" {
  description = "SQL service account username"
  type        = string
}

variable "sql_svc_acct_pswd" {
  description = "SQL service account password"
  type        = string
  default     = "'P@ssw0rd!234'"
  sensitive   = true
}

########## vm-dc1 VARIABLES
variable "vm_dc1_hostname" {
  description = "Hostname for the domain controller"
  type        = string
  default     = "vm-dc170" // fail if not unique in public DNS
}
variable "vm_dc1_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_dc1_shutdown_hhmm" {
  description = "Time for VM Shutdown (HHMM)"
  type        = string
  default     = "0015" // midnight ;-)
}

variable "dc1_domain_name" {
  description = "Domain name"
  type        = string
  default     = "mylab.mytenant.onmicrosoft.lan"
}

variable "dc1_domain_netbios_name" {
  description = "Domain NetBIOS name"
  type        = string
  default     = "MYLAB"
}
