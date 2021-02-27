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
  script_url                              = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/scripts/"
  #mediacomposerScript                    = "setupMediaComposer_${var.mediacomposerVersion}.ps1"
  #ProToolsScript                         = "setupProTools_${var.ProToolsVersion}.ps1"
  stored_subnet_id                        = module.editorial_networking.azurerm_subnet_ids
  DomainName                              = "ben01.internal"                                     
}

module "editorial_networking" {
  source                        = "./modules/network"
  vnet_name                     = "${var.resource_prefix}-rg-vnet" 
  resource_group_name           = local.resource_group_name
  resource_group_location       = var.resource_group_location
  address_space                 = var.vnet_address_space
  dns_servers                   = var.dns_servers
  subnets                       = var.subnets
  sg_name                       = "${var.resource_prefix}-rg-nsg"
  tags                          = var.azureTags
}

module "domaincontroller_deployment" {
  source                            = "./modules/domaincontroller"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  resource_prefix                 = var.resource_prefix
  resource_group_location         = var.resource_group_location
  DomainName                      = local.DomainName
  vnet_subnet_id                  = local.stored_subnet_id[0]
  domaincontroller_nb_instances   = var.domaincontroller_nb_instances
  script_url                      = local.script_url
  installers_url                  = var.installers_url
  depends_on                      = [module.editorial_networking]
}

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  resource_prefix               = var.resource_prefix
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  DomainName                    = local.DomainName
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_nb_instances          = var.jumpbox_nb_instances
  script_url                    = local.script_url
  JumpboxScript                 = var.JumpboxScript
  jumpbox_internet_access       = var.jumpbox_internet_access 
  installers_url                = var.installers_url
  AvidNexisInstaller            = var.AvidNexisInstaller
  depends_on                    = [module.domaincontroller_deployment]
}

module "protools_deployment" {
  source                            = "./modules/protools"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  resource_prefix                   = var.resource_prefix
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  gpu_type                          = var.gpu_type
  protools_vm_size                  = var.protools_vm_size
  protools_nb_instances             = var.protools_nb_instances
  protools_internet_access          = var.protools_internet_access
  script_url                        = local.script_url 
  #ProToolsScript                   = local.ProToolsScript
  TeradiciKey                       = var.TeradiciKey
  TeradiciInstaller                 = var.TeradiciInstaller
  installers_url                    = var.installers_url
  ProToolsVersion                   = var.ProToolsVersion
  AvidNexisInstaller                = var.AvidNexisInstaller
  depends_on                        = [module.editorial_networking]
}

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  admin_username                    = var.admin_username
  admin_password                    = var.admin_password
  script_url                        = local.script_url
  installers_url                    = var.installers_url
  resource_prefix                   = var.resource_prefix
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[0]
  gpu_type                          = var.gpu_type
  mediacomposer_vm_size             = var.mediacomposer_vm_size
  mediacomposer_nb_instances        = var.mediacomposer_nb_instances
  mediacomposer_internet_access     = var.mediacomposer_internet_access 
  TeradiciKey                       = var.TeradiciKey
  TeradiciInstaller                 = var.TeradiciInstaller
  mediacomposerVersion              = var.mediacomposerVersion
  AvidNexisInstaller                = var.AvidNexisInstaller 
  depends_on                        = [module.editorial_networking]
}

module "nexis_online_deployment" {
  source                              = "./modules/nexis"
  hostname                            = "${var.resource_prefix}on"
  admin_username                      = var.admin_username
  admin_password                      = var.admin_password
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[0]
  resource_prefix                     = var.resource_prefix 
  nexis_storage_vm_size               = var.nexis_vm_size
  nexis_storage_nb_instances          = var.nexis_online_nb_instances
  nexis_storage_vm_script_url         = local.script_url
  nexis_storage_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_storage_vm_artifacts_location = var.installers_url
  nexis_storage_vm_build              = var.nexis_storage_vm_build
  nexis_storage_vm_part_number        = var.nexis_storage_vm_part_number_online
  nexis_storage_performance           = var.nexis_storage_performance_online
  nexis_storage_replication           = var.nexis_storage_replication_online
  nexis_storage_account_kind          = var.nexis_storage_account_kind_online
  depends_on                          = [module.editorial_networking]
}

module "nexis_nearline_deployment" {
  source                              = "./modules/nexis"
  hostname                            = "${var.resource_prefix}nl"
  admin_username                      = var.admin_username
  admin_password                      = var.admin_password
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[0]
  resource_prefix                     = var.resource_prefix 
  nexis_storage_vm_size               = var.nexis_vm_size
  nexis_storage_nb_instances          = var.nexis_nearline_nb_instances
  nexis_storage_vm_script_url         = local.script_url
  nexis_storage_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_storage_vm_artifacts_location = var.installers_url
  nexis_storage_vm_build              = var.nexis_storage_vm_build
  nexis_storage_vm_part_number        = var.nexis_storage_vm_part_number_nearline
  nexis_storage_performance           = var.nexis_storage_performance_nearline
  nexis_storage_replication           = var.nexis_storage_replication_nearline
  nexis_storage_account_kind          = var.nexis_storage_account_kind_nearline
  depends_on                          = [module.editorial_networking]
}

module "zabbix_deployment" {
  source                        = "./modules/zabbix"
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  resource_prefix               = var.resource_prefix
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  zabbix_vm_size                = var.zabbix_vm_size
  zabbix_nb_instances           = var.zabbix_nb_instances
  script_url                    = local.script_url
  zabbixScript                  = var.zabbixScript
  zabbix_internet_access        = var.zabbix_internet_access 
  installers_url                = var.installers_url
  depends_on                    = [module.editorial_networking]
}