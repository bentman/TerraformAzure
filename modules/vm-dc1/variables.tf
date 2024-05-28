#################### VARIABLES ####################
########## vm common Variables
variable "vm_shutdown_tz" {
  description = "Time Zone for VM Shutdown"
  type        = string
  default     = "Pacific Standard Time"
}

variable "vm_localadmin_user" {
  description = "vm local admin username - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "localadmin"
  sensitive   = true
}

variable "vm_localadmin_pswd" {
  description = "vm local admin password - NOTE: becomes domain admin after dcpromo"
  type        = string
  default     = "P@ssw0rd!234"
  sensitive   = true
}

variable "vm_server_snet_id" {
  description = "vm-server subnet"
  type        = string
}

########## vm-addc 
variable "vm_dc1_hostname" {
  description = "Computername for domain controller"
  type        = string
  default     = "vm-dc1"
}

variable "vm_dc1_size" {
  description = "The size of the Virtual Machine(s) type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_dc1_shutdown_hhmm" {
  description = "Time for VM Shutdown HHMM"
  type        = string
  default     = "0000" // midnight ;-)
}

########## addc 
# domain name
variable "dc1_domain_name" {
  description = "domain name"
  type        = string
  default     = "lab.tenant.onmicrosoft.lan"
}

# domain netbios name
variable "dc1_domain_netbios_name" {
  description = "domain netbios name"
  type        = string
  default     = "LAB"
}

# domain safemode password
variable "dc1_safemode_admin_pswd" {
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
