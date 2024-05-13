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
    container_name       = "azure-devops-pipeline"
    key                  = "terraform.tfstate"
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

}
