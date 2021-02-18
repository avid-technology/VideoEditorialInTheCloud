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
  resource_group_name                     = "${var.resource_prefix}-rg"
  github_url                              = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/scripts/"
  mediacomposerScript                     = "setupMediaComposer_NVIDIA_${var.mediacomposerVersion}.ps1"
  stored_subnet_id                        = module.editorial_networking.azurerm_subnet_ids                                     
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

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  resource_prefix               = var.resource_prefix
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_nb_instances          = var.jumpbox_nb_instances
  JumpboxScript                 = "${local.github_url}${var.JumpboxScript}"
  jumpbox_internet_access       = var.jumpbox_internet_access 
  AvidNexisInstallerUrl         = "${var.storage_account_url}/${var.AvidNexisInstallerUrl}"
  depends_on                    = [module.editorial_networking]
}

module "protools_deployment" {
  source                            = "./modules/protools"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  resource_prefix                   = var.resource_prefix
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  gpu_type                          = "${var.gpu_type}GpuDriverWindows"
  protools_vm_size                  = var.protools_vm_size
  protools_nb_instances             = var.protools_nb_instances
  protools_internet_access          = var.protools_internet_access 
  ProToolsScript                    = "${local.github_url}${var.ProToolsScript}"
  TeradiciKey                       = var.TeradiciKey
  TeradiciURL                       = "${var.storage_account_url}/${var.TeradiciURL}"
  ProToolsURL                       = "${var.storage_account_url}/${var.ProToolsURL}"
  NvidiaURL                         = var.NvidiaURL
  AvidNexisInstallerUrl             = "${var.storage_account_url}/${var.AvidNexisInstallerUrl}"
  depends_on                        = [module.editorial_networking]
}

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  resource_prefix                   = var.resource_prefix
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  gpu_type                          = "${var.gpu_type}GpuDriverWindows"
  mediacomposer_vm_size             = var.mediacomposer_vm_size
  mediacomposer_nb_instances        = var.mediacomposer_nb_instances
  mediacomposer_internet_access     = var.mediacomposer_internet_access 
  github_url                        = local.github_url
  mediacomposerScript               = local.mediacomposerScript
  TeradiciKey                       = var.TeradiciKey
  TeradiciURL                       = "${var.storage_account_url}/${var.TeradiciURL}"
  mediacomposerURL                  = "${var.storage_account_url}/Media_Composer_${var.mediacomposerVersion}_Win.zip"
  NvidiaURL                         = var.NvidiaURL
  AvidNexisInstallerUrl             = "${var.storage_account_url}/${var.AvidNexisInstallerUrl}" 
  depends_on                        = [module.editorial_networking]
}

module "nexis_online_deployment" {
  source                              = "./modules/nexis"
  admin_username                      = var.admin_username
  admin_password                      = var.admin_password
  hostname                            = "${var.resource_prefix}on"
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[0]
  resource_prefix                     = var.resource_prefix 
  nexis_storage_vm_size               = var.nexis_vm_size
  nexis_storage_nb_instances          = var.nexis_online_nb_instances
  nexis_storage_vm_script_url         = local.github_url
  nexis_storage_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_storage_vm_artifacts_location = var.storage_account_url
  nexis_storage_vm_build              = var.nexis_storage_vm_build
  nexis_storage_vm_part_number        = var.nexis_storage_vm_part_number_online
  nexis_storage_performance           = var.nexis_storage_performance_online
  nexis_storage_replication           = var.nexis_storage_replication_online
  nexis_storage_account_kind          = var.nexis_storage_account_kind_online
  depends_on                          = [module.editorial_networking]
}

module "nexis_nearline_deployment" {
  source                              = "./modules/nexis"
  admin_username                      = var.admin_username
  admin_password                      = var.admin_password
  hostname                            = "${var.resource_prefix}nl"
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[0]
  resource_prefix                     = var.resource_prefix 
  nexis_storage_vm_size               = var.nexis_vm_size
  nexis_storage_nb_instances          = var.nexis_nearline_nb_instances
  nexis_storage_vm_script_url         = local.github_url
  nexis_storage_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_storage_vm_artifacts_location = var.storage_account_url
  nexis_storage_vm_build              = var.nexis_storage_vm_build
  nexis_storage_vm_part_number        = var.nexis_storage_vm_part_number_nearline
  nexis_storage_performance           = var.nexis_storage_performance_nearline
  nexis_storage_replication           = var.nexis_storage_replication_nearline
  nexis_storage_account_kind          = var.nexis_storage_account_kind_nearline
  depends_on                          = [module.editorial_networking]
}

