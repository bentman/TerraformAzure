variable "tags" {
  type = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}

variable "rg_location" {
  type        = string
  default     = "southcentralus"
  description = "Location of the resource group."
}

variable "vm_jumpwin_hostname" {
  type        = string
  default     = "tacocat007"
  description = "Computername for the windows-vm"
}

variable "vm_jumplin_hostname" {
  type        = string
  default     = "tacocat008"
  description = "Computername for the linux-vm"
}

##### Declare confidential variables here, specify values in *.tfvars (with .gitingnore file!) #####
variable "ARM_TENANT_ID" {
  type        = string
  description = "azure tenant id"
  sensitive   = true
}

variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "azure subscription id"
  sensitive   = true
}

variable "ARM_CLIENT_ID" {
  type        = string
  description = "azure service principle id"
  sensitive   = true
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "azure service principle secret"
  sensitive   = true
}

variable "ADMIN_USER" {
  type        = string
  description = "admin username"
  default     = "adminuser"
  sensitive   = true
}

variable "ADMIN_PSWD" {
  type        = string
  description = "adminuser password"
  default     = "P@ssw0rd!"
  sensitive   = true
}
