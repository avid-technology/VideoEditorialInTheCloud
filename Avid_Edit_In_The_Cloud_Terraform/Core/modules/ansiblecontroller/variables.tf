############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
 description = "Admin Password for Virtual Machines"
 sensitive   = true
}

variable "resource_group_name" {
  description = "Name of resource group where to build resources"
}

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_name" {
  description = "Name of vnet where resource will be built"
}

variable "subnet_name" {
  description = "Name of subnet where resource will be built"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "installers_url" {
  description = "Location of all the installers"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

############## Ansible controller Variables ##############

variable "ansiblecontroller_vm_hostname" {
  description = "Ansible controller hostname"
}

variable "ansiblecontroller_vm_size" {
  description = "Size of Ansible controller VM"
  default     = "Standard_D2s_v3"
}

variable "ansiblecontroller_nb_instances" {
  description = "Number of Ansible controller instances"
  default     = 0
}

variable "ansiblecontrollerScript" {
  description   = "Script name for Ansible controller"
  default       = "ansiblecontroller_v0.1.bash"
}

variable "ansiblecontroller_internet_access" {
  description = "Internet access for Ansible controller true or false"
  type        = bool
  default     = true 
}

