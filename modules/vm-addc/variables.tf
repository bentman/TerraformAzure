#################### VARIABLES ####################
########## vm-addc 
# Computername for domain controller
variable "vm_addc_hostname" {
  description = "Computername for domain controller"
  type        = string
  default     = "vmaddc"
}

# vm-server subnet
variable "vm_server_snet_id" {
  description = "vm-server subnet"
  type        = string
}

########## vm common Variables
# vm local admin username - NOTE: becomes domain admin after dcpromo
variable "vm_localadmin_user" {
  description = "vm local admin username - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "localadmin"
  sensitive   = true
}

# vm local admin password - NOTE: becomes domain admin after dcpromo
variable "vm_localadmin_pswd" {
  description = "vm local admin password - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

# The size of the Virtual Machine(s) type.
variable "vm_addc_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

# Time for VM Shutdown HHMM
variable "vm_addc_shutdown_hhmm" {
  description = "Time for VM Shutdown HHMM"
  type        = string
  default     = "0000" // midnight ;-)
}

# Time Zone for VM Shutdown
variable "vm_addc_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

########## addc 
# domain name
variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "mylab.mytenant.onmicrosoft.com"
}

# domain netbios name
variable "domain_netbios_name" {
  description = "domain netbios name"
  type        = string
  default     = "MYLAB"
}

# domain safemode password
variable "safemode_admin_pswd" {
  description = "domain safemode password"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

##### RESOURCE VARIABLES
# lab name (suggest 'lab', 'dev', 'qa', 'test', etc)
variable "lab_name" {
  description = "lab name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  type        = string
  default     = "mylab"
}

# azure region for lab
variable "rg_location" {
  description = "azure region for lab"
  type        = string
  default     = "westus"
}

# azure region for lab
variable "rg_name" {
  description = "resource group name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  type        = string
  default     = "rg-mylab"
}

# A map of tags to assign to the resources
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}
