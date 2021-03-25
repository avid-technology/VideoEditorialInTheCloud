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

locals {
  resource_prefix       = "abc0" # Max 4 characters                                   
}

# data "azurerm_subnet" "data_subnet_workstations" {
#   name                 = "subnet_workstations"
#   virtual_network_name = "abc0-rg-vnet"
#   resource_group_name  = "abc0-rg"
# }

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  local_admin_username              = "avid-admin"
  local_admin_password              = "Avid1234567$"
  domainName                        = ""
  domain_admin_username             = ""
  domain_admin_password             = ""
  script_url                        = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/release/0.0.4/Avid_Edit_In_The_Cloud_Terraform/Workstations/scripts/" 
  installers_url                    = "https://eitcstore01.blob.core.windows.net/installers/"
  resource_group_name               = "avid-eastus2-rad-01"
  resource_group_location           = "eastus2"
  vnet_subnet_id                    = data.azurerm_subnet.data_subnet_workstations.id
  gpu_type                          = "Nvidia"    # Either Nvidia or Amd
  mediacomposer_vm_hostname         = "${local.resource_prefix}-mc"
  mediacomposer_vm_size             = "Standard_NV12s_v3" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  mediacomposer_nb_instances        = 1
  mediacomposer_internet_access     = true
  mediacomposerScript               = "setupMediaComposer_v0.2.ps1" 
  mediacomposerVersion              = "2020.12.0"    # Options available: 2018.12.14, 2020.12.0, 2021.2.0
  TeradiciKey                       = "0000"
  TeradiciInstaller                 = "pcoip-agent-graphics_21.01.4.exe"
  AvidNexisInstaller                = "AvidNEXISClient_Win64_20.7.5.23.msi" 
}

module "protools_deployment" {
  source                            = "./modules/protools"
  local_admin_username              = "local-admin-01"
  local_admin_password              = "password123!"
  domainName                        = ""
  domain_admin_username             = ""
  domain_admin_password             = ""
  script_url                        = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/Workstations/scripts/" 
  installers_url                    = "https://eitcstore01.blob.core.windows.net/installers/"
  resource_group_name               = "${local.resource_prefix}-rg"
  resource_group_location           = "southcentralus"
  vnet_subnet_id                    = data.azurerm_subnet.data_subnet_workstations.id
  gpu_type                          = "Nvidia"
  protools_vm_hostname              = "${local.resource_prefix}-pt"
  protools_vm_size                  = "Standard_NV12s_v3" # Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3
  protools_nb_instances             = 0
  protools_internet_access          = false
  protoolsScript                    = "setupProTools_v0.1.ps1"
  ProToolsVersion                   = "2020.11.0"
  TeradiciKey                       = ""
  TeradiciInstaller                 = "pcoip-agent-graphics_21.01.2.exe"
  AvidNexisInstaller                = "AvidNEXISClient_Win64_21.3.0.21.msi"
}
