locals{
  nexis_storage_vm_script_url         = "${element(split(",", lookup(var.nexis_storage_configuration, var.nexis_storage_type, "")), 0)}"
  nexis_storage_vm_script_name        = "${element(split(",", lookup(var.nexis_storage_configuration, var.nexis_storage_type, "")), 1)}"
  nexis_storage_vm_artifacts_location = "${element(split(",", lookup(var.nexis_storage_configuration, var.nexis_storage_type, "")), 2)}"
  nexis_storage_vm_build              = "${element(split(",", lookup(var.nexis_storage_configuration, var.nexis_storage_type, "")), 3)}"
  nexis_storage_vm_part_number        = "${element(split(",", lookup(var.nexis_storage_configuration, var.nexis_storage_type, "")), 4)}"
  nexis_storage_performance           = "${element(split(",", lookup(var.nexis_storage_account_configuration, var.nexis_storage_type, "")), 0)}"
  nexis_storage_replication           = "${element(split(",", lookup(var.nexis_storage_account_configuration, var.nexis_storage_type, "")), 1)}"
  nexis_storage_account_kind          = "${element(split(",", lookup(var.nexis_storage_account_configuration, var.nexis_storage_type, "")), 2)}"
}

resource "random_string" "nexis" {
    length  = 5
    special = false
    upper   = false
}

#############################
# Storage Account for Nexis #
#############################
resource "azurerm_storage_account" "nexis_storage_account" {
  count                     = var.nexis_storage_nb_instances
  name                      = "${var.hostname}${random_string.nexis.result}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_kind              = local.nexis_storage_account_kind
  account_tier              = local.nexis_storage_performance
  account_replication_type  = local.nexis_storage_replication
  depends_on = [ random_string.nexis]
}

resource "azurerm_private_endpoint" "nexis_storage_account" {
  count               = var.nexis_storage_nb_instances
  name                = "${var.hostname}${random_string.nexis.result}-pe"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  subnet_id           = var.vnet_subnet_id
  depends_on = [ random_string.nexis]

  private_service_connection {
    name                           = "${var.hostname}${random_string.nexis.result}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.nexis_storage_account.*.id[0]
    subresource_names              = ["blob"]
  } 
}

resource "azurerm_network_interface" "nic" {
  count                         = var.nexis_storage_nb_instances
  name                          = "${var.hostname}-nic"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = ""
  }
}

resource "azurerm_virtual_machine" "vm-linux-with-datadisk" {
  count                         = var.nexis_storage_nb_instances
  name                          = var.hostname
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  vm_size                       = var.nexis_storage_vm_size
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]

  storage_image_reference {
    publisher = "debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "1024"
  }

  storage_data_disk {
    name              = "${var.hostname}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "768"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = var.hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}

resource "azurerm_virtual_machine_extension" "nexis_storage_servers" {
  count                 = var.nexis_storage_nb_instances
  name                  = var.hostname
  virtual_machine_id    = azurerm_virtual_machine.vm-linux-with-datadisk[count.index].id
  publisher             = "Microsoft.Azure.Extensions"
  type                  = "CustomScript"
  type_handler_version  = "2.0"
  depends_on            = [azurerm_virtual_machine.vm-linux-with-datadisk]

  settings = <<EOF
    {
       "commandToExecute": "wget '${local.nexis_storage_vm_script_url}' -O ${local.nexis_storage_vm_script_name} && echo ${var.admin_password} | sudo -S /bin/bash ${local.nexis_storage_vm_script_name} ${var.hostname} ${local.nexis_storage_vm_artifacts_location} ${local.nexis_storage_vm_build} ${local.nexis_storage_vm_part_number}" 
    }
  EOF
}