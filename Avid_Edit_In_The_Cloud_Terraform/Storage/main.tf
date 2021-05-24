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

# Example with private visibility to storage account and no public access to system director
module "nexis_online_deployment" {
  source                                      = "./modules/cloud_nexis_system_director"
  hostname                                    = "pocon"
  local_admin_username                        = "local-admin"
  local_admin_password                        = "Password123$"
  resource_group_location                     = "southcentralus"
  vnet_name                                   = "poc-rg-vnet"
  subnet_name                                 = "subnet_storage"
  resource_group_name                         = "poc-rg"
  nexis_storage_account_public_access         = false 
  nexis_system_director_vm_size               = "Standard_DS4_v2" # Either Standard_F16s_v2 (production) or Standard_DS4_v2 (testing)
  nexis_system_director_nb_instances          = 1
  nexis_storage_account_performance           = "Premium"
  nexis_storage_account_replication           = "LRS"
  nexis_storage_account_kind                  = "BlockBlobStorage"
  nexis_system_director_internet_access       = false
  nexis_system_director_image_reference       = {
                                                publisher = "debian"          # Either "Credativ" or "debian"
                                                offer     = "debian-10"       # Either "Debian" or "debian-10"
                                                sku       = "10"              # Either "8" or "10"
                                                version   = "latest"          # Either "8.0.201901221" or "0.20210208.542"
                                              }
}

# Example with public visibility to storage account and public access to system director
module "nexis_nearline_deployment" {
  source                                      = "./modules/cloud_nexis_system_director"
  hostname                                    = "pocnl"
  local_admin_username                        = "local-admin"
  local_admin_password                        = "Password123$"
  resource_group_location                     = "southcentralus"
  vnet_name                                   = "poc-rg-vnet"
  subnet_name                                 = "subnet_storage"
  resource_group_name                         = "poc-rg"
  nexis_storage_account_public_access         = true
  nexis_system_director_vm_size               = "Standard_DS4_v2"
  nexis_system_director_nb_instances          = 0
  nexis_storage_account_performance           = "Standard"
  nexis_storage_account_replication           = "LRS"
  nexis_storage_account_kind                  = "StorageV2"
  nexis_system_director_internet_access       = false
  nexis_system_director_image_reference       = {
                                                publisher = "debian"          # Either "Credativ" or "debian"
                                                offer     = "debian-10"       # Either "Debian" or "debian-10"
                                                sku       = "10"              # Either "8" or "10"
                                                version   = "latest"          # Either "8.0.201901221" or "0.20210208.542"
                                              }
}

module "nexis_centos_client_deployment" {
  source                        = "./modules/cloud_nexis_centos_client"
  local_admin_username          = "local-admin"
  local_admin_password          = "Password123$"
  resource_group_name           = "poc-rg"
  resource_group_location       = "southcentralus"
  vnet_name                     = "poc-rg-vnet"
  subnet_name                   = "subnet_storage"
  nexis_client_vm_hostname      = "poc-cl"
  nexis_client_vm_size          = "Standard_DS1_v2"
  nexis_client_nb_instances     = 0
  nexis_client_internet_access  = false
}
