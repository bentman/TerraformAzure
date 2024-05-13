#################### PROVIDERS ####################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  tenant_id       = var.arm_tenant_id
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}
