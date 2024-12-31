terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.46.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "sa1_test_eic_MaazPatel"
    storage_account_name = "terraformremotestate24"
    container_name       = "tfstate"
    key                  = "dev.terrakube.tfstate"
  }
}

provider "azurerm" {
  features {
    # virtual_machine {
    #   delete_os_disk_on_deletion     = true
    #   skip_shutdown_and_force_delete = true
    # }  
  }
  skip_provider_registration = true

  # tenant_id       = var.tenant_id
  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
}
