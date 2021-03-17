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

data "azurerm_subnet" "data_subnet_mediacentral" {
  name                 = "subnet_mediacentral"
  virtual_network_name = "abc2-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

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
  vnet_subnet_id                    = data.azurerm_subnet.data_subnet_mediacentral.id
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
  vnet_subnet_id                        = data.azurerm_subnet.data_subnet_mediacentral.id
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
  vnet_subnet_id                        = data.azurerm_subnet.data_subnet_mediacentral.id
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
  vnet_subnet_id                = data.azurerm_subnet.data_subnet_mediacentral.id
  mccloudux_vm_size             = "Standard_D16s_v3"
  mccloudux_nb_instances        = var.mccloudux_nb_instances
  script_url                    = local.script_url
  mccloudux_internet_access     = true
  installers_url                = var.installers_url
  depends_on                    = [module.editorial_networking]
}
