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

##### RESOURCE VARIABLES
variable "lab_name" {
  description = "The name of the lab environment ('lab', 'dev', 'qa', 'test', etc.)"
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
  default     = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}

########## vm-jumpBox
# vm-jumpWin Hostname
variable "vm_jumpwin_hostname" {
  description = "Computer name for the Windows VM jumpbox"
  type        = string
  default     = "jumpwin007" // fail if not unique in public DNS
}

# vm-jumpLin Hostname
variable "vm_jumplin_hostname" {
  description = "Computer name for the Linux VM jumpbox"
  type        = string
  default     = "jumplin008" // fail if not unique in public DNS
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

########## vm-addc
variable "vm_addc_hostname" {
  description = "Computer name for the domain controller"
  type        = string
  default     = "vmaddc"
}

variable "vm_addc_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_addc_shutdown_hhmm" {
  description = "Time for VM Shutdown (HHMM)"
  type        = string
  default     = "0000" // midnight ;-)
}

variable "vm_addc_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

########## addc 
variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "mylab.onmicrosoft.lan"
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
  default     = "P@ssw0rd!"
  sensitive   = true
}

########## vm-sqlha 
variable "vm_sqlha_hostname" {
  description = "Computername for vm-sqlha appended by vm_sqlha_count #"
  type        = string
  default     = "vm-sqlha" //  no more than a total of 14 char + vm_sqlha_count
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

variable "sqlcluster_name" {
  description = "Name of the SQL cluster"
  type        = string
}

variable "sqlaag_name" {
  description = "Name of the SQL AG (Availability Group)"
  type        = string
}

variable "sql_sysadmin_login" {
  description = "SQL sysadmin username"
  type        = string
}

variable "sql_sysadmin_password" {
  description = "SQL sysadmin password"
  type        = string
  sensitive   = true
}

variable "sql_service_account_login" {
  description = "SQL service account username"
  type        = string
}

variable "sql_service_account_password" {
  description = "SQL service account password"
  type        = string
  sensitive   = true
}
