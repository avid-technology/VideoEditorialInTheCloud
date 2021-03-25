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
#   resource_group_name   = "${var.resource_prefix}-rg"
#   script_url            = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/Remote/scripts/"                                   
# }

# data "azurerm_subnet" "data_subnet_remote" {
#   name                 = "subnet_remote"
#   virtual_network_name = "${var.resource_prefix}-rg-vnet"
#   resource_group_name  = "${var.resource_prefix}-rg"
# }

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  domain_admin_username         = ""
  domain_admin_password         = ""
  domainName                    = ""
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_remote"
  script_url                    = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/release/0.0.4/Avid_Edit_In_The_Cloud_Terraform/Remote/scripts/"
  installers_url                = "https://eitcstore01.blob.core.windows.net/installers/"
  jumpbox_vm_hostname           = "poc-jx"
  jumpbox_vm_size               = "Standard_D4s_v3"
  jumpbox_nb_instances          = 1
  JumpboxScript                 = "jumpbox_v0.1.ps1"
  jumpbox_internet_access       = true 
}

module "teradicicac_deployment" {
  source                        = "./modules/teradici_cac"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_remote"
  teradicicac_vm_hostname       = "poc-cac"
  teradicicac_vm_size           = "Standard_D2s_v3"
  teradicicac_nb_instances      = 0
  script_url                    = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/release/0.0.4/Avid_Edit_In_The_Cloud_Terraform/Core/scripts/"
  teradicicacScript             = "teradicicac_v0.1.bash"
  teradicicac_internet_access   = true
  installers_url                = "https://eitcstore01.blob.core.windows.net/installers/"
}