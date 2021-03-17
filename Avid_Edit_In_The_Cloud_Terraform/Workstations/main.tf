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
  #stored_subnet_id      = module.editorial_networking.azurerm_subnet_ids                                    
}

#0: Core | 1: Mediacentral | 2: Monitor | 3: Remote | 4: Storage | 5: Transfer | 6: Workstations

########################## Core ##########################

data "azurerm_subnet" "data_subnet_workstations" {
  name                 = "subnet_workstations"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

module "mediacomposer_deployment" {
  source                            = "./modules/workstations/mediacomposer"
  local_admin_username              = var.local_admin_username
  local_admin_password              = var.local_admin_password
  domainName                        = var.domainName
  domain_admin_username             = var.domain_admin_username
  domain_admin_password             = var.domain_admin_password
  script_url                        = local.script_url
  installers_url                    = var.installers_url
  resource_group_name               = "${var.resource_prefix}-rg"
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = data.azurerm_subnet.data_subnet_workstations.id
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
}

module "protools_deployment" {
  source                            = "./modules/workstations/protools"
  resource_group_name               = "${var.resource_prefix}-rg"
  resource_group_location           = var.resource_group_location
  vnet_subnet_id                    = data.azurerm_subnet.data_subnet_workstations.id
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
}
