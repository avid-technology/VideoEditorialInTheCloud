#########################
# Input Variables       #
#########################

variable "admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_prefix" {
  description = "4 max characters to prefix each resource built"
}

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_subnet_id" {
  description = "Subnet where resources will be built"
}

variable "mediacomposer_vm_size" {
  description = "Size of MediaComposer VM. Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3."
  default     = "Standard_NV12s_v3"
}

variable "mediacomposer_nb_instances" {
  description = "Number of MediaComposer instances"
  default     = 0
}

variable "mediacomposer_internet_access" {
    type        = bool
    default     = false 
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "TeradiciKey" {
    type    = string  
    default = "0000"  
}

variable "installers_url" {
  description = "Path to scripts location"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

variable "TeradiciInstaller" {
    type    = string 
    default = "pcoip-agent-graphics_21.01.2.exe"
}

variable "mediacomposerVersion" {   
    type        = string 
    description = "Options available: 2018.12.14, 2020.12.0, 2021.2.0"
    default     = "2021.2.0"
}

variable "AvidNexisInstaller" {
    type = string 
    default = "AvidNEXISClient_Win64_20.12.0.9.msi"
}

variable "gpu_type" {
    description = "Gpu type either Nvidia or Amd"
    type = string 
}

