#################### VARIABLES ####################
########## vm-sqlha 

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

sqlcluster_name              = "sqlcluster"   // vm sqlha clustername, 12 character recommended
sqlaag_name                  = "sqlhaaoaag"   // vm sqlha avail group, 12 character recommended
sql_sysadmin_login           = "neo"          // sql sysadmin username
sql_sysadmin_password        = "1RedpBlup!"   // sql sysadmin password
sql_service_account_login    = "sqlsvc"       // sql service username
sql_service_account_password = "M3r0v1ng1@n!" // sql service password

# vm common Variables
variable "vm_localadmin_user" {
  type        = string
  default     = "localadmin"
  description = "vm local admin username - NOTE: becomes domain admin after dcpromo"
  sensitive   = true
}

variable "vm_localadmin_pswd" {
  type        = string
  default     = "P@ssw0rd!234"
  description = "vm local admin password - NOTE: becomes domain admin after dcpromo"
  sensitive   = true
}

########## addc 
variable "domain_name" {
  type        = string
  default     = "mylab.mytenant.onmicrosoft.com"
  description = "domain name"
}

variable "domain_netbios_name" {
  type        = string
  default     = "MYLAB"
  description = "domain netbios name"
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

variable "rg_name" {
  type        = string
  default     = "rg-mylab"
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
