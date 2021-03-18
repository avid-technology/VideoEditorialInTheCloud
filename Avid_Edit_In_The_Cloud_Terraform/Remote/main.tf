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
  resource_group_name   = "${var.resource_prefix}-rg"
  script_url            = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/Remote/scripts/"                                   
}

data "azurerm_subnet" "data_subnet_remote" {
  name                 = "subnet_remote"
  virtual_network_name = "${var.resource_prefix}-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  domain_admin_username         = var.domain_admin_username
  domain_admin_password         = var.domain_admin_password
  domainName                    = var.domainName
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = data.azurerm_subnet.data_subnet_remote.id
  script_url                    = local.script_url
  installers_url                = var.installers_url
  jumpbox_vm_hostname           = "${var.resource_prefix}-jx"
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_nb_instances          = var.jumpbox_nb_instances
  JumpboxScript                 = var.JumpboxScript
  jumpbox_internet_access       = var.jumpbox_internet_access 
}

module "teradicicac_deployment" {
  source                        = "./modules/teradici_cac"
  local_admin_username          = var.local_admin_username
  #local_admin_password         = var.local_admin_password
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = data.azurerm_subnet.data_subnet_remote.id
  teradicicac_vm_hostname       = "${var.resource_prefix}-cac"
  teradicicac_vm_size           = "Standard_D2s_v3"
  teradicicac_nb_instances      = var.teradicicac_nb_instances
  script_url                    = local.script_url
  teradicicacScript             = "teradicicac_v0.1.bash"
  teradicicac_internet_access   = true
  installers_url                = var.installers_url
}