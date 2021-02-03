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

module "editorial_networking" {
  source                  = "./modules/network"
  vnet_name               = "${var.resource_group_name}-vnet" 
  resource_group_name     = "${var.resource_prefix}-rg"
  resource_group_location = var.resource_group_location
  address_space           = var.vnet_address_space
  dns_servers             = var.dns_servers
  subnets                 = var.subnets
  sg_name                 = "${var.resource_group_name}-nsg"
  tags                    = var.azureTags
}

locals {
  stored_subnet_id                = module.editorial_networking.azurerm_subnet_ids
}

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  resource_group_name           = var.resource_group_name
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  jumpbox_vm_hostname           = "${var.resource_prefix}-jpbx"
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_vm_instances          = var.jumpbox_vm_instances
  depends_on                    = [module.editorial_networking]
}

module "protools_deployment" {
  source                            = "./modules/protools"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  resource_group_name               = var.resource_group_name
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  protools_vm_hostname              = "${var.resource_prefix}-ptls"
  protools_vm_size                  = var.protools_vm_size
  protools_vm_instances             = var.protools_vm_instances
  depends_on                        = [module.editorial_networking]
}

