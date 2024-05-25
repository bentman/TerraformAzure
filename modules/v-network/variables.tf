#################### VARIABLES ####################
########## v-network
# v-network subnet names
variable "snet_0000_jumpbox" {
  description = "Name of the subnet for the jumpbox"
  type        = string
  default     = "snet-0.000-jumpbox"
}

variable "snet_0032_gateway" {
  description = "Name of the subnet for the gateway"
  type        = string
  default     = "snet-0.032-gateway"
}

variable "snet_0064_db1" {
  description = "Name of the subnet for the first database"
  type        = string
  default     = "snet-0.064-db1"
}

variable "snet_0096_db2" {
  description = "Name of the subnet for the second database"
  type        = string
  default     = "snet-0.096-db2"
}

variable "snet_0128_server" {
  description = "Name of the subnet for the servers"
  type        = string
  default     = "snet-0.128-server"
}

variable "snet_1000_client" {
  description = "Name of the subnet for the clients"
  type        = string
  default     = "snet-1.000-client"
}
##### RESOURCE VARIABLES
variable "lab_name" {
  description = "The name of the lab environment ('lab', 'dev', 'qa', 'test', etc.)"
  type        = string
  default     = "mylab"
}

variable "rg_location" {
  description = "Azure region for lab"
  type        = string
  default     = "westus"
}

variable "rg_name" {
  description = "resource group name (suggest 'lab', 'dev', 'qa', 'test', etc)"
  type        = string
  default     = "rg-mylab"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}
