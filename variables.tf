#################### VARIABLES ####################
########## SECRETS VARIABLES 
#####  Declare confidential variables here
#####  Store secret values in *.tfvars file
#####  Check .gitingnore in repo for details
########## SECRETS VARIABLES 

variable "arm_tenant_id" {
  type        = string
  description = "azure tenant id"
  sensitive   = true
}

variable "arm_subscription_id" {
  type        = string
  description = "azure subscription id"
  sensitive   = true
}

variable "arm_client_id" {
  type        = string
  description = "azure service principle id"
  sensitive   = true
}

variable "arm_client_secret" {
  type        = string
  description = "azure service principle secret"
  sensitive   = true
}

variable "vm_localadmin_user" {
  type        = string
  default     = "localadmin"
  description = "vm local admin username"
  sensitive   = true
}

variable "vm_localadmin_pswd" {
  type        = string
  default     = "P@ssw0rd!234"
  description = "vm local admin password"
  sensitive   = true
}

##### RESOURCE VARIABLES
variable "lab_name" {
  type        = string
  default     = "mylab"
  description = "lab name (suggest 'lab', 'dev', 'qa', 'test', etc)"
}

variable "rg_location" {
  type        = string
  default     = "westus"
  description = "azure region for lab"
}

variable "tags" {
  type = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}

########## vm-jumpBox
# vm-jumpWin Hostname
variable "vm_jumpwin_hostname" {
  type        = string
  default     = "jumpwin007" // fail if not unique in public DNS
  description = "Computername for the windows-vm jumpbox"
}
# vm-jumpLin Hostname
variable "vm_jumplin_hostname" {
  type        = string
  default     = "jumplin008" // fail if not unique in public DNS
  description = "Computername for the linux-vm jumpbox"
}

# vm common Variables
variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3" // 2 x vCPU + 8gb RAM
  description = "The size of the Virtual Machine(s) type."
}

variable "vm_shutdown_hhmm" {
  type        = string
  default     = "0000" // midnight ;-)
  description = "Time for VM Shutdown HHMM"
}

variable "vm_shutdown_tz" {
  type        = string
  default     = "Pacific Standard Time"
  description = "Time Zone for VM Shutdown"
}

########## vm-addc
# vm-addc Hostname
variable "vm_addc_hostname" {
  type        = string
  default     = "vmaddc"
  description = "Computername for domain controller"
}

variable "vm_addc_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The size of the Virtual Machine(s) type."
}

variable "vm_addc_shutdown_hhmm" {
  type        = string
  default     = "0000" // midnight ;-)
  description = "Time for VM Shutdown HHMM"
}

variable "vm_addc_shutdown_tz" {
  type        = string
  default     = "Pacific Standard Time"
  description = "Time Zone for VM Shutdown"
}

########## addc 
variable "domain_name" {
  type        = string
  default     = "mylab.onmicrosoft.lan"
  description = "domain name"
}

variable "domain_netbios_name" {
  type        = string
  default     = "MYLAB"
  description = "domain netbios name"
}

variable "domain_admin_user" {
  type        = string
  default     = "domainadmin"
  description = "admin username"
  sensitive   = true
}

variable "domain_admin_pswd" {
  type        = string
  default     = "P@ssw0rd!234"
  description = "domainadmin password"
  sensitive   = true
}

variable "safemode_admin_pswd" {
  type        = string
  default     = "P@ssw0rd!"
  description = "domain safemode password"
  sensitive   = true
}

/*########## vm-sqlha 
variable "vm_sqlha_hostname" {
  type        = string
  default     = "vmsqlha"
  description = "Computername prefix for sqlha cluster servers"
}

# vm-sqlha subnet-db1
variable "snet_sqlha_0064_db1" {
  type        = string
  description = "vm-sqlha server subnet-db1"
}

# vm-sqlha subnet-db2
variable "snet_sqlha_0096_db2" {
  type        = string
  description = "vm-sqlha server subnet-db2"
}

variable "vm_sqlha_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The size of the Virtual Machine(s) type."
}

variable "vm_sqlha_shutdown_hhmm" {
  type        = string
  default     = "0000" // midnight ;-)
  description = "Time for VM Shutdown HHMM"
}

variable "vm_sqlha_shutdown_tz" {
  type        = string
  default     = "Pacific Standard Time"
  description = "Time Zone for VM Shutdown"
}
*/
/*
sqlcluster_name              
sqlaag_name                  
sql_sysadmin_login           
sql_sysadmin_password        
sql_service_account_login    
sql_service_account_password 
*/
