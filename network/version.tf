terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.68.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.48.0"
    }
  }
}