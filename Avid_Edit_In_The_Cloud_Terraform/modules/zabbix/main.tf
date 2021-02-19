locals{
  resource_group_name         = "${var.resource_prefix}-rg"
  hostname                    = "${var.resource_prefix}-zbx"
  nexis_storage_vm_script_url = "${var.nexis_storage_vm_script_url}${var.nexis_storage_vm_script_name}"
}

resource "azurerm_network_interface" "zabbix_nic" {
  count                         = var.zabbix_nb_instances
  name                          = "${local.hostname}${format("%02d",count.index)}-nic"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = ""
  }
}

resource "azurerm_virtual_machine" "zabbix_vm" {
  count                         = var.nexis_storage_nb_instances
  name                          = "${local.hostname}${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  vm_size                       = var.nexis_storage_vm_size
  network_interface_ids         = [azurerm_network_interface.nexis_nic[count.index].id]

  storage_image_reference {
    publisher = "debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.hostname}${format("%02d",count.index)}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "1024"
  }

  storage_data_disk {
    name              = "${local.hostname}${format("%02d",count.index)}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "768"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${local.hostname}${format("%02d",count.index)}"
    admin_username = "avid"
    admin_password = var.admin_password
    custom_data    = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}

resource "azurerm_virtual_machine_extension" "nexis_storage_servers" {
  count                 = var.nexis_storage_nb_instances
  name                  = "nexis"
  virtual_machine_id    = azurerm_virtual_machine.nexis_vm[count.index].id
  publisher             = "Microsoft.Azure.Extensions"
  type                  = "CustomScript"
  type_handler_version  = "2.0"
  depends_on            = [azurerm_virtual_machine.nexis_vm]

  settings = <<EOF
    {
       "commandToExecute": "wget '${local.nexis_storage_vm_script_url}' -O ${var.nexis_storage_vm_script_name} && echo ${var.admin_password} | sudo -S /bin/bash ${var.nexis_storage_vm_script_name} ${local.hostname}${format("%02d",count.index)} ${var.nexis_storage_vm_artifacts_location} ${var.nexis_storage_vm_build} ${var.nexis_storage_vm_part_number}" 
    }
  EOF
}