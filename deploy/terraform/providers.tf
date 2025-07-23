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
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "fabric" {
}

provider "azuredevops" {
  org_service_url = var.ado_org_service_url
}

provider "time" {}
