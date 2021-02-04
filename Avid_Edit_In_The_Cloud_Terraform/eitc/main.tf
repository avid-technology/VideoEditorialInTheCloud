# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {
  version = "~> 2.2"
}

locals {
  resource_group_name= "${var.resource_prefix}-rg"
}

module "editorial_networking" {
  source                  = "./modules/network"
  vnet_name               = "${var.resource_prefix}-rg-vnet" 
  resource_group_name     = local.resource_group_name
  resource_group_location = var.resource_group_location
  address_space           = var.vnet_address_space
  dns_servers             = var.dns_servers
  subnets                 = var.subnets
  sg_name                 = "${var.resource_prefix}-rg-nsg"
  tags                    = var.azureTags
}

locals {
  stored_subnet_id                = module.editorial_networking.azurerm_subnet_ids
}

resource "random_string" "general" {
  length  = 5
  special = false
  upper   = false
}

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  resource_group_name           = local.resource_group_name
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  jumpbox_vm_hostname           = "${var.resource_prefix}-jpbx"
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_nb_instances          = var.jumpbox_nb_instances
  jumpbox_internet_access       = var.jumpbox_internet_access 
  depends_on                    = [module.editorial_networking]
}

module "protools_deployment" {
  source                            = "./modules/protools"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  resource_group_name               = local.resource_group_name
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  protools_vm_hostname              = "${var.resource_prefix}-pt"
  protools_vm_size                  = var.protools_vm_size
  protools_nb_instances             = var.protools_nb_instances
  protools_internet_access          = var.protools_internet_access 
  ProToolsScriptURL                 = var.ProToolsScriptURL
  TeradiciKey                       = var.TeradiciKey
  TeradiciURL                       = var.TeradiciURL
  ProToolsURL                       = var.ProToolsURL
  NvidiaURL                         = var.NvidiaURL
  AvidNexisInstallerUrl             = var.AvidNexisInstallerUrl 
  depends_on                        = [module.editorial_networking]
}

module "nexis_deployment" {
  source                              = "./modules/nexis"
  hostname                            = "${var.resource_prefix}nx00"
  admin_username                      = var.admin_username
  admin_password                      = var.admin_password
  resource_group_name                 = local.resource_group_name
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[1]
  source_address_prefix               = var.resource_prefix 
  nexis_storage_configuration         = var.nexis_storage_configuration
  nexis_storage_account_configuration = var.nexis_storage_account_configuration
  nexis_storage_type                  = var.nexis_type
  nexis_storage_vm_size               = var.nexis_vm_size
  nexis_storage_nb_instances          = var.nexis_nb_instances
  depends_on                          = [module.editorial_networking]
}

