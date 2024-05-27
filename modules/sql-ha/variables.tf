#################### VARIABLES ####################

##### RESOURCE VARIABLES
variable "lab_name" {
  description = "lab name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  type        = string
  default     = "mylab"
}

variable "rg_name" {
  description = "azure region for lab"
  type        = string
  default     = "rg-mylab"
}

variable "rg_location" {
  description = "azure region for lab"
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
  description = "domain safemode password"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

########## vm-addc common
variable "vm_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

########## vm-addc
variable "snet_0128_server_id" {
  description = "The ID of the subnet 0128 db1"
  type        = string
}

variable "vm_addc_hostname" {
  description = "Computername for domain controller"
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
  default     = "0010" // midnight + 10m ;-)
}

variable "vm_addc_localadmin_user" {
  description = "vm local admin username - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "localadmin"
}

variable "vm_addc_localadmin_pswd" {
  description = "vm local admin password - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

########## vm-sqlha 
variable "vm_sqlha_count" {
  description = "The number of SQL HA virtual machine - Currently only supported 2!"
  type        = number
  default     = 2
}

variable "vm_sqlha_hostname" {
  description = "Computername for vm-sqlha appended by vm_sqlha_count #"
  type        = string
  default     = "vm-sqlha" // maximum of 14 char
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

########## sqlha 
variable "sqlaag_name" {
  description = "Name of the SQL AG (Availability Group)"
  type        = string
}

variable "sqlcluster_name" {
  description = "Name of the SQL cluster"
  type        = string
}

variable "snet_0064_db1_id" {
  description = "The ID of the subnet 0064 db1"
  type        = string
}

variable "snet_0096_db2_id" {
  description = "The ID of the subnet 0096 db2"
  type        = string
}

variable "snet_0064_db1_prefixes" {
  description = "The address prefixes of the subnet 0064 db1"
  type        = list(string)
}

variable "snet_0096_db2_prefixes" {
  description = "The address prefixes of the subnet 0096 db2"
  type        = list(string)
}

# vm common Variables
variable "vm_sqlha_localadmin_user" {
  description = "vm local admin username - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "localadmin"
  sensitive   = true
}

variable "vm_sqlha_localadmin_pswd" {
  description = "vm local admin password - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

variable "sql_sysadmin_user" {
  description = "SQL sysadmin username"
  type        = string
}

variable "sql_sysadmin_pswd" {
  description = "SQL sysadmin password"
  type        = string
  sensitive   = true
}

variable "sql_svc_acct_user" {
  description = "SQL service account username"
  type        = string
}

variable "sql_svc_acct_pswd" {
  description = "SQL service account password"
  type        = string
  sensitive   = true
}

variable "vm_sqlha_image_publisher" {
  description = "(Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "MicrosoftSQLServer"
}

variable "vm_sqlha_image_offer" {
  description = "(Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "sql2022-ws2022"
}

variable "vm_sqlha_image_sku" {
  description = "(Required) Specifies the SKU of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "sqldev-gen2"
}

variable "sqldatafilepath" {
  description = "(Required) The SQL Server default data path"
  type        = string
  default     = "K:\\Data"
}

variable "sqllogfilepath" {
  description = "(Required) The SQL Server default log path"
  type        = string
  default     = "L:\\Logs"
}

variable "sqltempfilepath" {
  description = "(Required) The SQL Server default temp path"
  type        = string
  default     = "T:\\Temp"
}

variable "sql_image_offer" {
  description = "(Required) The offer type of the marketplace image cluster to be used by the SQL Virtual Machine Group. Changing this forces a new resource to be created."
  type        = string
  default     = "SQL2022-WS2022"
}

variable "sql_image_sku" {
  description = " (Required) The sku type of the marketplace image cluster to be used by the SQL Virtual Machine Group. Possible values are Developer and Enterprise."
  type        = string
  default     = "Developer"
}

variable "vm_addc_public_ip" {
  description = "Domain Controller Public IP"
  type        = string
}

variable "vm_addc_private_ip" {
  description = "Domain Controller Private IP"
  type        = string
}
