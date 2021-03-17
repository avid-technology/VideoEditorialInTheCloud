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
}

data "azurerm_subnet" "data_subnet_storage" {
  name                 = "subnet_storage"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

data "azurerm_subnet" "data_subnet_workstations" {
  name                 = "subnet_workstations"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

data "azurerm_subnet" "data_subnet_transfer" {
  name                 = "subnet_transfer"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

data "azurerm_subnet" "data_subnet_mediacentral" {
  name                 = "subnet_mediacentral"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

module "nexis_online_deployment" {
  source                                      = "./modules/nexis"
  hostname                                    = "${var.resource_prefix}on"
  local_admin_username                        = var.local_admin_username
  local_admin_password                        = var.local_admin_password
  resource_group_location                     = var.resource_group_location
  vnet_subnet_id                              = data.azurerm_subnet.data_subnet_storage.id
  resource_group_name                         = "${var.resource_prefix}-rg"
  nexis_storage_account_public_access         = false 
  nexis_storage_account_subnet_access         = [data.azurerm_subnet.data_subnet_storage.id,data.azurerm_subnet.data_subnet_workstations.id,data.azurerm_subnet.data_subnet_transfer.id,data.azurerm_subnet.data_subnet_mediacentral.id]
  private_dns_zone_resource_group             = "${var.resource_prefix}-rg"
  nexis_system_director_vm_size               = var.nexis_vm_size
  nexis_system_director_nb_instances          = var.nexis_online_nb_instances
  nexis_system_director_vm_script_url         = local.script_url
  nexis_system_director_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_system_director_vm_artifacts_location = var.installers_url
  nexis_system_director_vm_build              = var.nexis_storage_vm_build
  nexis_system_director_vm_part_number        = var.nexis_storage_vm_part_number_online
  nexis_system_director_performance           = var.nexis_storage_performance_online
  nexis_system_director_replication           = var.nexis_storage_replication_online
  nexis_system_director_account_kind          = var.nexis_storage_account_kind_online
  nexis_system_director_internet_access       = false
  nexis_system_director_image_reference       = var.nexis_image_reference
}

module "nexis_nearline_deployment" {
  source                                      = "./modules/nexis"
  hostname                                    = "${var.resource_prefix}nl"
  local_admin_username                        = var.local_admin_username
  local_admin_password                        = var.local_admin_password
  resource_group_location                     = var.resource_group_location
  vnet_subnet_id                              = data.azurerm_subnet.data_subnet_storage.id
  resource_group_name                         = "${var.resource_prefix}-rg"
  nexis_storage_account_public_access         = true
  nexis_storage_account_subnet_access         = []  
  private_dns_zone_resource_group             = ""
  nexis_system_director_vm_size               = var.nexis_vm_size
  nexis_system_director_nb_instances          = var.nexis_nearline_nb_instances
  nexis_system_director_vm_script_url         = local.script_url
  nexis_system_director_vm_script_name        = var.nexis_storage_vm_script_name
  nexis_system_director_vm_artifacts_location = var.installers_url
  nexis_system_director_vm_build              = var.nexis_storage_vm_build
  nexis_system_director_vm_part_number        = var.nexis_storage_vm_part_number_nearline
  nexis_system_director_performance           = var.nexis_storage_performance_nearline
  nexis_system_director_replication           = var.nexis_storage_replication_nearline
  nexis_system_director_account_kind          = var.nexis_storage_account_kind_nearline
  nexis_system_director_internet_access       = true
  nexis_system_director_image_reference       = var.nexis_image_reference
}
