# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }  
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_client_config" "current" {}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

