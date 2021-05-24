# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
    random = {
      version = "~> 2.2"
    }
  }
}

provider "azurerm" {
  features {}
}

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  local_admin_username              = "local-admin"
  local_admin_password              = "Password123$"
  script_url                        = "https://eitcstore01.blob.core.windows.net/scripts/" 
  sas_token                         = var.sas_token
  resource_group_name               = "poc-rg"
  resource_group_location           = "southcentralus"
  vnet_name                         = "poc-rg-vnet"
  image_reference                   = {
                                      publisher = "MicrosoftWindowsDesktop"
                                      offer     = "Windows-10"
                                      sku       = "20h2-pro"
                                      version   = "latest"
                                      }
  subnet_name                       = "subnet_workstations"
  mediacomposer_vm_hostname         = "poc-mc"
  mediacomposer_vm_size             = "Standard_NV12s_v3" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  mediacomposer_nb_instances        = 1
  mediacomposer_internet_access     = false
  mediacomposerScript               = "ConfigureRemotingForAnsible.ps1"
}

module "protools_deployment" {
  source                            = "./modules/protools"
  local_admin_username              = "local-admin"
  local_admin_password              = "Password123$"
  script_url                        = "https://eitcstore01.blob.core.windows.net/scripts/" 
  sas_token                         = var.sas_token
  resource_group_name               = "poc-rg"
  resource_group_location           = "southcentralus"
  vnet_name                         = "poc-rg-vnet"
  image_reference                   = {
                                      publisher = "MicrosoftWindowsDesktop"
                                      offer     = "Windows-10"
                                      sku       = "20h2-pro"
                                      version   = "latest"
                                      }
  subnet_name                       = "subnet_workstations"
  protools_vm_hostname              = "poc-pt"
  protools_vm_size                  = "Standard_NV12s_v3" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  protools_nb_instances             = 1
  protools_internet_access          = false
  protoolsScript                    = "ConfigureRemotingForAnsible.ps1"
}
