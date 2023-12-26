variable "tags" {
  type = map(string)
  default = {
    "environment" = "lab"
    "project"     = "learning"
    "source"      = "terraform"
  }
}

variable "resource_group_location" {
  type        = string
  default     = "southcentralus"
  description = "Location of the resource group."
}

variable "rg_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name prefix."
}

variable "vnet_name_prefix" {
  type        = string
  default     = "vnet"
  description = "Prefix of the virtual network name."
}

variable "snet_name_prefix" {
  type        = string
  default     = "snet"
  description = "Prefix of the virtual subnet name."
}

variable "vm_name_prefix" {
  type        = string
  default     = "vm"
  description = "Prefix of the virtual machine name."
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
