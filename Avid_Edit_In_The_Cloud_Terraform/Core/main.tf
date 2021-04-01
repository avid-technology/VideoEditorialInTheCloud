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

module "editorial_networking" {
  source                        = "./modules/network"
  vnet_name                     = "poc-rg-vnet" 
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  address_space                 = ["10.1.0.0/16"]
  dns_servers                   = []
  create_subnet_Mediacentral    = true
  create_subnet_Monitor         = true
  create_subnet_Remote          = true
  create_subnet_Storage         = true
  create_subnet_Transfer        = true
  create_subnet_Workstations    = true  
  # Subnet core is always created by default
  subnets                       = { 
                                        subnet_core="10.1.0.0/24"
                                        subnet_mediacentral="10.1.1.0/24"
                                        subnet_monitor="10.1.2.0/24"
                                        subnet_remote="10.1.3.0/24"
                                        subnet_storage="10.1.4.0/24"
                                        subnet_transfer="10.1.5.0/24"
                                        subnet_workstations="10.1.6.0/24"
                                  }
  tags                          = { 
                                        environment="EITC" 
                                      }
}

module "domaincontroller_deployment" {
  source                            = "./modules/domaincontroller"
  local_admin_username              = "local-admin"
  local_admin_password              = "Password123$"
  resource_group_name               = "poc-rg"
  resource_group_location           = "southcentralus"
  #domainName                        = "poc.internal"
  vnet_name                         = "poc-rg-vnet"
  subnet_name                       = "subnet_core"
  script_url                        = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/Core/scripts/"
  installers_url                    = "https://eitcstore01.blob.core.windows.net/installers/"
  domaincontroller_vm_size          = "Standard_D4s_v3"
  domaincontroller_vm_hostname      = "poc-dc"
  domaincontroller_nb_instances     = 1
  domaincontroller_internet_access  = true
  depends_on                        = [module.editorial_networking]
}

# resource "azurerm_private_dns_zone" "private_dns_zone_storage_account" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = "poc-rg"
#   depends_on          = [module.editorial_networking]
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_storage_account_link" {
#   name                  = "blob_private_zone_dns_vnet_link"
#   resource_group_name   = "poc-rg"
#   private_dns_zone_name = "privatelink.blob.core.windows.net"
#   virtual_network_id    = module.editorial_networking.vnet_id
#   depends_on            = [azurerm_private_dns_zone.private_dns_zone_storage_account]
# }