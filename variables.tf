variable "tags" {
  type = map(string)
  default = {
    "environment" = "lab"
    "project"     = "learning"
    "source"      = "terraform"
  }
}

variable "rg_location" {
  type        = string
  default     = "southcentralus"
  description = "Location of the resource group."
}

variable "vm-jumpwin_hostname" {
  type = string
  default = "tacocat007"
  description = "Computername for the linux-vm"
}

variable "vm-jumplin_hostname" {
  type = string
  default = "tacocat008"
  description = "Computername for the linux-vm"
}

// Declare confidential variables here, specify values in *.tfvars (with .gitingnore file!)

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
  description = "adminuser"
  sensitive   = true
}
variable "ADMIN_PSWD" {
  type        = string
  description = "adminuser password"
  sensitive   = true
}
