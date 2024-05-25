variable "rg_location" {
  description = "Region where resources are created"
  type        = string
  default     = "eastus2"
}

variable "rg_name" {
  description = "Name of resource group where resources are created"
  type        = string
  default     = "rg-tzo-p1-eu2"
}

variable "tags" {
  type = map(string)
  default = {
    "source"      = "terraform"
    "project"     = "learning"
    "environment" = "lab"
  }
}
