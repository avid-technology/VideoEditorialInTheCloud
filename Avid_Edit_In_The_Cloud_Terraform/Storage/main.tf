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
  source                                      = "./modules/nexis"
  hostname                                    = "pocon"
  local_admin_username                        = "local-admin"
  local_admin_password                        = "Password123$"
  resource_group_location                     = "southcentralus"
  vnet_name                                   = "poc-rg-vnet"
  subnet_name                                 = "subnet_storage"
  resource_group_name                         = "poc-rg"
  nexis_storage_account_public_access         = false 
  # nexis_storage_account_subnet_access         = ["subnet_remote","subnet_mediacentral"]
  # private_dns_zone_resource_group             = "poc-rg"
  nexis_system_director_vm_size               = "Standard_F16s_v2"
  nexis_system_director_nb_instances          = 1
  nexis_system_director_vm_script_url         = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/Storage/scripts/"
  nexis_system_director_vm_script_name        = "installNexis.bash"
  nexis_system_director_vm_artifacts_location = "https://eitcstore01.blob.core.windows.net/installers/"
  nexis_system_director_vm_build              = "AvidNEXISCloud_21.3.0-21.run"
  nexis_system_director_vm_part_number        = "0100-40109-00"
  nexis_system_director_performance           = "Premium"
  nexis_system_director_replication           = "LRS"
  nexis_system_director_account_kind          = "BlockBlobStorage"
  nexis_system_director_internet_access       = false
  nexis_system_director_image_reference       = {
                                                publisher = "debian"          # Either "Credativ" or "debian"
                                                offer     = "debian-10"       # Either "Debian" or "debian-10"
                                                sku       = "10"              # Either "8" or "10"
                                                version   = "0.20210208.542"          # Either "8.0.201901221" or "0.20210208.542"
                                              }
}

# Example with public visibility to storage account and public access to system director
module "nexis_nearline_deployment" {
  source                                      = "./modules/nexis"
  hostname                                    = "pocnl"
  local_admin_username                        = "local-admin"
  local_admin_password                        = "Password123$"
  resource_group_location                     = "southcentralus"
  vnet_name                                   = "poc-rg-vnet"
  subnet_name                                 = "subnet_storage"
  resource_group_name                         = "poc-rg"
  nexis_storage_account_public_access         = true
  # nexis_storage_account_subnet_access         = []  
  # private_dns_zone_resource_group             = ""
  nexis_system_director_vm_size               = "Standard_F16s_v2"
  nexis_system_director_nb_instances          = 1
  nexis_system_director_vm_script_url         = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/Storage/scripts/"
  nexis_system_director_vm_script_name        = "installNexis.bash"
  nexis_system_director_vm_artifacts_location = "https://eitcstore01.blob.core.windows.net/installers/"
  nexis_system_director_vm_build              = "AvidNEXISCloud_21.3.0-21.run"
  nexis_system_director_vm_part_number        = "0100-38171-00"
  nexis_system_director_performance           = "Standard"
  nexis_system_director_replication           = "LRS"
  nexis_system_director_account_kind          = "StorageV2"
  nexis_system_director_internet_access       = false
  nexis_system_director_image_reference       = {
                                                publisher = "debian"          # Either "Credativ" or "debian"
                                                offer     = "debian-10"       # Either "Debian" or "debian-10"
                                                sku       = "10"              # Either "8" or "10"
                                                version   = "0.20210208.542"          # Either "8.0.201901221" or "0.20210208.542"
                                              }
}
