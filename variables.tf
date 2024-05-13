#################### VARIABLES ####################
########## SECRETS VARIABLES ##########
#####  Declare confidential variables here
#####  Store secret values in *.tfvars file
#####  Check .gitingnore in repo for details
########## SECRETS VARIABLES ##########

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

variable "vm_localadmin_username" {
  type        = string
  description = "vm local admin username"
  default     = "localadmin"
  sensitive   = true
}

variable "vm_localadmin_password" {
  type        = string
  description = "vm local admin password"
  default     = "P@ssw0rd!"
  sensitive   = true
}

#################### VARIABLES - w/ default values ####################
variable "lab_name" {
  type        = string
  description = "lab name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  default     = "mylab"
}

variable "resource_group_region" {
  type        = string
  description = "azure region for lab"
  default     = "westus"
}

variable "tags" {
  type = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}

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
