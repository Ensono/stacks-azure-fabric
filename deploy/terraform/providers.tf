terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.1"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }

  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "fabric" {
}

provider "azapi" {}
