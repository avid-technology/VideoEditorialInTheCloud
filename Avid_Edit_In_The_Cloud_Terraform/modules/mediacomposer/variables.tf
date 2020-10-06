#########################
# Input Variables       #
#########################
variable "hostname" {
  description = "description"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "mediacomposer_vm_number_public_ip" {
  description = "description"
  default = 0
}

variable "mediacomposer_vm_remote_port" {
  description = "description"
  default = 3389
}

variable "mediacomposer_vm_instances" {
  description = "description"
}

variable "mediacomposer_vm_size" {
  description = "description"
}

variable "resource_group_name" {
  description = ""
}

variable "resource_group_location" {
  description = ""
}

variable "subnet_id" {
  description = ""
}

variable "source_address_prefix" {
  description = "CIDR or source IP range or * to match any IP. Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used."
  default = "*"
}

variable "base_index" {
  description = "Base index"
  default = 0
}

variable "tags" {
  description = "description"
}

variable "proximity_placement_group_id" {
  description = "The proximity placement group for VMs"
}

#########################
# General Variables     #
#########################
resource "random_string" "mediacomposer" {
    length  = 5
    special = false
    upper   = false
}

#########################
# Maps                  #
#########################
variable "software_install_urls" {
  default ={
    "mediacomposer_vm_script_url"   = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/setupMediaComposer_NVIDIA_20204.ps1"
    "avid_nexis_client_url"         = "https://benstore01.blob.core.windows.net/installers/AvidNEXIS_20.7.0_Client.zip"
    "mediaComposer_url"             = "https://benstore01.blob.core.windows.net/installers/Media_Composer_2020.4._Win.zip"
    "teradici_url"                  = "https://benstore01.blob.core.windows.net/installers/pcoip-agent-graphics_20.04.0.exe"
    "nvidia_url"                    = "https://benstore01.blob.core.windows.net/installers/442.06_grid_win10_64bit_international_whql.exe"
    "teradici_key"                  = "No_Key"
  }
}