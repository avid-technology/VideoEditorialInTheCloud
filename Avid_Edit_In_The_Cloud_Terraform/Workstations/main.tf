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

# locals {
#   resource_prefix       = "abc0" # Max 4 characters                                   
# }

# data "azurerm_subnet" "data_subnet_workstations" {
#   name                 = "subnet_workstations"
#   virtual_network_name = "abc0-rg-vnet"
#   resource_group_name  = "abc0-rg"
# }

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  local_admin_username              = "local-admin"
  local_admin_password              = "Password123$"
  domainName                        = "poc.internal"
  domain_admin_username             = "domain-admin"
  domain_admin_password             = "Password123!"
  script_url                        = "https://eitcstore01.blob.core.windows.net/scripts/" 
  installers_url                    = "https://eitcstore01.blob.core.windows.net/installers/"
  resource_group_name               = "poc-rg"
  resource_group_location           = "southcentralus"
  vnet_name                         = "poc-rg-vnet"
  subnet_name                       = "subnet_workstations"
  gpu_type                          = "Amd"    # Either Nvidia or Amd
  mediacomposer_vm_hostname         = "poc-mc"
  mediacomposer_vm_size             = "Standard_NV16as_v4" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  mediacomposer_nb_instances        = 1
  mediacomposer_internet_access     = false
  mediacomposerScript               = "ConfigureRemotingForAnsible.ps1" 
  mediacomposerVersion              = "2021.3.0"    # Options available: 2018.12.14, 2020.12.0, 2021.3.0
  TeradiciKey                       = "0000"
  TeradiciInstaller                 = "pcoip-agent-graphics_21.03.0.exe"
  AvidNexisInstaller                = "AvidNEXISClient_Win64_21.3.0.21.msi" 
}

module "protools_deployment" {
  source                            = "./modules/protools"
  local_admin_username              = "local-admin"
  local_admin_password              = "Password123$"
  domainName                        = "poc.internal"
  domain_admin_username             = "domain-admin"
  domain_admin_password             = "Password123!"
  script_url                        = "https://eitcstore01.blob.core.windows.net/scripts/" 
  installers_url                    = "https://eitcstore01.blob.core.windows.net/installers/"
  resource_group_name               = "poc-rg"
  resource_group_location           = "southcentralus"
  vnet_name                         = "poc-rg-vnet"
  subnet_name                       = "subnet_workstations"
  gpu_type                          = "Nvidia"
  protools_vm_hostname              = "poc-pt"
  protools_vm_size                  = "Standard_NV12s_v3" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  protools_nb_instances             = 0
  protools_internet_access          = false
  protoolsScript                    = "setupProTools_v0.1.ps1"
  ProToolsVersion                   = "2020.11.0"   # Options available: 2020.11.0
  TeradiciKey                       = "0000"
  TeradiciInstaller                 = "pcoip-agent-graphics_21.03.0.exe"
  AvidNexisInstaller                = "AvidNEXISClient_Win64_21.3.0.21.msi"
}
