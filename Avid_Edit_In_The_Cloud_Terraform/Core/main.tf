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

module "editorial_networking" {
  source                        = "./modules/network"
  vnet_name                     = "${var.resource_prefix}-rg-vnet" 
  resource_group_name           = local.resource_group_name
  resource_group_location       = var.resource_group_location
  address_space                 = var.vnet_address_space
  dns_servers                   = var.dns_servers
  create_subnet_Mediacentral    = true
  create_subnet_Monitor         = true
  create_subnet_Remote          = true
  create_subnet_Storage         = true
  create_subnet_Transfer        = true
  create_subnet_Workstations    = true
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
  vnet_subnet_id                    = module.editorial_networking.subnet_core_id
  script_url                        = local.script_url
  installers_url                    = var.installers_url
  domaincontroller_vm_size          = "Standard_D4s_v3"
  domaincontroller_vm_hostname      = "${var.resource_prefix}-dc"
  domaincontroller_nb_instances     = var.domaincontroller_nb_instances
  domaincontroller_internet_access  = true
  depends_on                        = [module.editorial_networking]
}