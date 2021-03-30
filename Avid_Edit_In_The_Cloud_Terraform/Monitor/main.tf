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

# locals {
#   resource_group_name   = "${var.resource_prefix}-rg"
#   script_url            = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/${var.branch}/Avid_Edit_In_The_Cloud_Terraform/Workstations/scripts/"                                    
# }

# data "azurerm_subnet" "data_subnet_monitor" {
#   name                 = "subnet_monitor"
#   virtual_network_name = "${var.resource_prefix}-rg-vnet"
#   resource_group_name  = "${var.resource_prefix}-rg"
# }

module "zabbix_deployment" {
  source                        = "./modules/zabbix"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  zabbix_vm_hostname            = "poc-zbx"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_monitor"
  zabbix_vm_size                = "Standard_D4s_v3"
  zabbix_nb_instances           = 1
  script_url                    = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/Workstations/scripts/"
  #zabbixScript                  = var.zabbixScript
  zabbix_internet_access        = true
  installers_url                = "https://eitcstore01.blob.core.windows.net/installers/"
}
