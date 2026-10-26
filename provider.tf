terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.68.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "storeaccghgy"
    container_name       = "terraform-state-dev"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
    # access_key = "ACCESS-KEYS"
    # subscription_id      = "SUBSCRIPTION-ID"
    # tenant_id            = "TENANT-ID"
    resource_group_name  = "azure-terraform-git"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}