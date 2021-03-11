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
  script_url            = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/scripts/"
  stored_subnet_id      = module.editorial_networking.azurerm_subnet_ids                                    
}

#0: Core | 1: MediaCentral | 2: Monitor | 3: Remote | 4: Storage | 5: Transfer | 6: Workstations

########################## Core ##########################

module "editorial_networking" {
  source                        = "./modules/network"
  vnet_name                     = "${var.resource_prefix}-rg-vnet" 
  resource_group_name           = local.resource_group_name
  resource_group_location       = var.resource_group_location
  address_space                 = var.vnet_address_space
  dns_servers                   = var.dns_servers
  whitelist_ip                  = var.whitelist_ip
  subnets                       = var.subnets
  tags                          = var.azureTags
}

module "domaincontroller_deployment" {
  source                            = "./modules/domaincontroller"
  local_admin_username              = var.local_admin_username
  local_admin_password              = var.local_admin_password
  resource_group_name               = "${var.resource_prefix}-rg"
  resource_group_location           = var.resource_group_location
  domainName                        = var.domainName
  vnet_subnet_id                    = local.stored_subnet_id[0]
  script_url                        = local.script_url
  installers_url                    = var.installers_url
  domaincontroller_vm_size          = "Standard_D4s_v3"
  domaincontroller_vm_hostname      = "${var.resource_prefix}-dc"
  domaincontroller_nb_instances     = var.domaincontroller_nb_instances
  domaincontroller_internet_access  = false
  depends_on                        = [module.editorial_networking]
}

########################## Remote ##########################

module "jumpbox_deployment" {
  source                        = "./modules/jumpbox"
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  domain_admin_username         = var.domain_admin_username
  domain_admin_password         = var.domain_admin_password
  domainName                    = var.domainName
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[3]
  script_url                    = local.script_url
  installers_url                = var.installers_url
  #AvidNexisInstaller            = var.AvidNexisInstaller
  jumpbox_vm_hostname           = "${var.resource_prefix}-jx"
  jumpbox_vm_size               = var.jumpbox_vm_size
  jumpbox_nb_instances          = var.jumpbox_nb_instances
  JumpboxScript                 = var.JumpboxScript
  jumpbox_internet_access       = var.jumpbox_internet_access 
  depends_on                    = [module.domaincontroller_deployment]
}

module "teradicicac_deployment" {
  source                        = "./modules/teradici/teradici_cac"
  local_admin_username          = var.local_admin_username
  #local_admin_password         = var.local_admin_password
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[3]
  teradicicac_vm_hostname       = "${var.resource_prefix}-cac"
  teradicicac_vm_size           = "Standard_D2s_v3"
  teradicicac_nb_instances      = var.teradicicac_nb_instances
  script_url                    = local.script_url
  teradicicacScript             = "teradicicac_v0.1.bash"
  teradicicac_internet_access   = true
  installers_url                = var.installers_url
  depends_on                    = [module.editorial_networking]
}

########################## Workstations ##########################

module "mediacomposer_deployment" {
  source                            = "./modules/mediacomposer"
  local_admin_username              = var.local_admin_username
  local_admin_password              = var.local_admin_password
  domainName                        = var.domainName
  domain_admin_username             = var.domain_admin_username
  domain_admin_password             = var.domain_admin_password
  script_url                        = local.script_url
  installers_url                    = var.installers_url
  resource_group_name               = "${var.resource_prefix}-rg"
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[6]
  gpu_type                          = var.gpu_type
  mediacomposer_vm_hostname         = "${var.resource_prefix}-mc"
  mediacomposer_vm_size             = var.mediacomposer_vm_size
  mediacomposer_nb_instances        = var.mediacomposer_nb_instances
  mediacomposer_internet_access     = var.mediacomposer_internet_access
  mediacomposerScript               = var.mediacomposerScript 
  mediacomposerVersion              = var.mediacomposerVersion
  TeradiciKey                       = var.TeradiciKey
  TeradiciInstaller                 = var.TeradiciInstaller
  AvidNexisInstaller                = var.AvidNexisInstaller 
  depends_on                        = [module.editorial_networking]
}

module "protools_deployment" {
  source                            = "./modules/protools"
  resource_group_name               = "${var.resource_prefix}-rg"
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = local.stored_subnet_id[6]
  gpu_type                          = var.gpu_type
  script_url                        = local.script_url 
  installers_url                    = var.installers_url
  local_admin_username              = var.local_admin_username
  local_admin_password              = var.local_admin_password
  domainName                        = var.domainName
  domain_admin_username             = var.domain_admin_username
  domain_admin_password             = var.domain_admin_password
  protools_vm_hostname              = "${var.resource_prefix}-pt"
  protools_vm_size                  = var.protools_vm_size
  protools_nb_instances             = var.protools_nb_instances
  protools_internet_access          = var.protools_internet_access
  protoolsScript                    = var.protoolsScript 
  ProToolsVersion                   = var.ProToolsVersion
  TeradiciKey                       = var.TeradiciKey
  TeradiciInstaller                 = var.TeradiciInstaller
  AvidNexisInstaller                = var.AvidNexisInstaller
  depends_on                        = [module.editorial_networking]
}

########################## MediaCentral ##########################

module "mccenterdeployment" {
  source                            = "./modules/mediacentral/mccenter"
  local_admin_username              = var.local_admin_username
  local_admin_password              = var.local_admin_password
  domain_admin_username             = var.domain_admin_username
  domain_admin_password             = var.domain_admin_password
  domainName                        = var.domainName
  resource_prefix                   = var.resource_prefix
  resource_group_location           = var.resource_group_location
  installers_url                    = var.installers_url
  vnet_subnet_id                    = local.stored_subnet_id[0]
  mccenter_vm_size                  = "Standard_D16s_v3"
  mccenter_nb_instances             = var.mccenter_nb_instances
  mcamversion                       = "2020_9"
  script_url                        = local.script_url
  mccenterScript                    = "mccenter_v0.1.ps1"
  mccenter_internet_access          = false 
  depends_on                        = [module.domaincontroller_deployment]
}

module "mccentersqldeployment" {
  source                                = "./modules/mediacentral/mccentersql"
  local_admin_username                  = var.local_admin_username
  local_admin_password                  = var.local_admin_password
  domain_admin_username                 = var.domain_admin_username
  domain_admin_password                 = var.domain_admin_password
  domainName                            = var.domainName
  resource_prefix                       = var.resource_prefix
  resource_group_location               = var.resource_group_location
  installers_url                        = var.installers_url
  vnet_subnet_id                        = local.stored_subnet_id[0]
  mccentersql_vm_size                   = "Standard_D8s_v3"
  mccentersql_nb_instances              = var.mccentersql_nb_instances
  script_url                            = local.script_url
  mccentersqlScript                     = "mccentersql_v0.1.ps1"
  mccentersql_internet_access           = false 
  depends_on                            = [module.domaincontroller_deployment]
}

module "mcworkerdeployment" {
  source                                = "./modules/mediacentral/mcworker"
  local_admin_username                  = var.local_admin_username
  local_admin_password                  = var.local_admin_password
  domain_admin_username                 = var.domain_admin_username
  domain_admin_password                 = var.domain_admin_password
  domainName                            = var.domainName
  resource_prefix                       = var.resource_prefix
  resource_group_location               = var.resource_group_location
  installers_url                        = var.installers_url
  vnet_subnet_id                        = local.stored_subnet_id[0]
  mcworker_vm_size                      = "Standard_D8s_v3"
  mcworker_nb_instances                 = var.mcworker_nb_instances
  script_url                            = local.script_url
  mcamversion                           = "2020_9"
  mcworkerScript                        = "mccservice_v0.1.ps1"
  mcworker_internet_access              = false 
  depends_on                            = [module.domaincontroller_deployment]
}

module "mccloudux_deployment" {
  source                        = "./modules/mediacentral/mccloudux"
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  resource_prefix               = var.resource_prefix
  resource_group_location       = var.resource_group_location
  vnet_subnet_id                = local.stored_subnet_id[0]
  mccloudux_vm_size             = "Standard_D16s_v3"
  mccloudux_nb_instances        = 0
  script_url                    = local.script_url
  mccloudux_internet_access     = true
  installers_url                = var.installers_url
  depends_on                    = [module.editorial_networking]
}

########################## Storage ##########################

module "nexis_online_deployment" {
  source                              = "./modules/nexis"
  hostname                            = "${var.resource_prefix}on"
  local_admin_username                = var.local_admin_username
  local_admin_password                = var.local_admin_password
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[4]
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
  nexis_internet_access               = var.nexis_internet_access
  nexis_image_reference               = var.nexis_image_reference
  depends_on                          = [module.editorial_networking]
}

module "nexis_nearline_deployment" {
  source                              = "./modules/nexis"
  hostname                            = "${var.resource_prefix}nl"
  local_admin_username                = var.local_admin_username
  local_admin_password                = var.local_admin_password
  resource_group_location             = var.resource_group_location
  vnet_subnet_id                      = local.stored_subnet_id[4]
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
  nexis_internet_access               = var.nexis_internet_access
  nexis_image_reference               = var.nexis_image_reference
  depends_on                          = [module.editorial_networking]
}

########################## Monitor ##########################

module "zabbix_deployment" {
  source                        = "./modules/zabbix"
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  zabbix_vm_hostname            = "${var.resource_prefix}-zbx"
  vnet_subnet_id                = local.stored_subnet_id[0]
  zabbix_vm_size                = var.zabbix_vm_size
  zabbix_nb_instances           = var.zabbix_nb_instances
  script_url                    = local.script_url
  zabbixScript                  = var.zabbixScript
  zabbix_internet_access        = var.zabbix_internet_access 
  installers_url                = var.installers_url
  depends_on                    = [module.editorial_networking]
}