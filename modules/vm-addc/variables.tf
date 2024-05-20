#################### VARIABLES ####################
########## vm-addc 
variable "vm_addc_hostname" {
  type        = string
  default     = "vmaddc"
  description = "Computername for domain controller"
}

# vm-addc subnet
variable "vm_server_snet_id" {
  type        = string
  description = "vm-server subnet"
}

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
  default     = "mylab.mytenant.onmicrosoft.com"
  description = "domain name"
}

variable "domain_netbios_name" {
  type        = string
  default     = "MYLAB"
  description = "domain netbios name"
}

variable "safemode_admin_pswd" {
  type        = string
  default     = "P@ssw0rd!234"
  description = "domain safemode password"
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
