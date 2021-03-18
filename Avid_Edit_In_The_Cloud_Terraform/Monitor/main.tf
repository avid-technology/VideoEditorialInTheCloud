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
  script_url            = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/Workstations/scripts/"                                    
}

data "azurerm_subnet" "data_subnet_monitor" {
  name                 = "subnet_monitor"
  virtual_network_name = "${var.resource_prefix}-rg-vnet"
  resource_group_name  = "${var.resource_prefix}-rg"
}

module "zabbix_deployment" {
  source                        = "./modules/zabbix"
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  resource_group_name           = "${var.resource_prefix}-rg"
  resource_group_location       = var.resource_group_location
  zabbix_vm_hostname            = "${var.resource_prefix}-zbx"
  vnet_subnet_id                = data.azurerm_subnet.data_subnet_monitor.id
  zabbix_vm_size                = var.zabbix_vm_size
  zabbix_nb_instances           = var.zabbix_nb_instances
  script_url                    = local.script_url
  zabbixScript                  = var.zabbixScript
  zabbix_internet_access        = var.zabbix_internet_access 
  installers_url                = var.installers_url
}
