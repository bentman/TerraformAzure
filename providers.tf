#################### PROVIDERS ####################
# Define the required providers and Terraform version
terraform {
  required_providers {
    # AzureRM provider for managing Azure resources
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # Random provider for generating random values
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    # Null provider for using null resources
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    # TLS provider for managing TLS certificates
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }
  # Specify the required Terraform version
  required_version = ">= 1.1.0"
}

# Configure the AzureRM provider with necessary credentials
provider "azurerm" {
  features {
    resource_group {
      # Prevent deletion of resource groups that contain resources
      prevent_deletion_if_contains_resources = false
    }
  }

  tenant_id       = var.arm_tenant_id
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
}
