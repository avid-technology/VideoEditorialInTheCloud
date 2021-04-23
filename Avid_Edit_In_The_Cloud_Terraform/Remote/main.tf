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

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  domain_admin_username         = "domain-admin"
  domain_admin_password         = "Password123!"
  domainName                    = "poc.internal"
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_remote"
  script_url                    = "https://eitcstore01.blob.core.windows.net/scripts/"
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
  teradicicac_nb_instances      = 1
  script_url                    = "https://eitcstore01.blob.core.windows.net/scripts/"
  # teradicicacScript             = "teradicicac_v0.1.bash"
  teradicicac_internet_access   = true
  installers_url                = "https://eitcstore01.blob.core.windows.net/installers/"
}

module "teradicicam_deployment" {
  source                        = "./modules/teradici_cam"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_remote"
  teradicicam_vm_hostname       = "poc-cam"
  teradicicam_vm_size           = "Standard_D4_v3"
  teradicicam_nb_instances      = 1
  script_url                    = "https://eitcstore01.blob.core.windows.net/scripts/"
  # teradicicamScript             = "teradicicac_v0.1.bash"
  teradicicam_internet_access   = false
  installers_url                = "https://eitcstore01.blob.core.windows.net/installers/"
}