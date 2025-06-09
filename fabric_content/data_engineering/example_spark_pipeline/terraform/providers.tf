terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    fabric = {
      source  = "microsoft/fabric"
      version = "1.1.0"
    }
  }

  backend "azurerm" {}

}

provider "azurerm" {
  features {}
}

provider "fabric" {}
