locals{
  resource_group_name         = "${var.resource_prefix}-rg"
  hostname                    = "${var.resource_prefix}-mcux"
}

resource "azurerm_public_ip" "mccloudux_ip" {
  count               = var.mccloudux_internet_access ? var.mccloudux_nb_instances : 0
  name                = "${local.hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mccloudux_nic" {
  count                         = var.mccloudux_nb_instances
  name                          = "${local.hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.mccloudux_internet_access ? azurerm_public_ip.mccloudux_ip[count.index].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "mccloudux_vm" {
  count                             = var.mccloudux_nb_instances
  name                              = "${local.hostname}-${format("%02d",count.index)}"
  location                          = var.resource_group_location
  resource_group_name               = local.resource_group_name
  size                              = var.mccloudux_vm_size
  admin_username                    = var.local_admin_username
  admin_password                    = var.local_admin_password
  computer_name                     = "${local.hostname}-${format("%02d",count.index)}"
  disable_password_authentication   = false
  network_interface_ids             = [azurerm_network_interface.mccloudux_nic[count.index].id]

admin_ssh_key {
  username   = var.local_admin_username
  public_key = file("~/.ssh/id_rsa.pub")
  }

 source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_8"
    version   = "7.8.2020100700"
  }

  os_disk {
    name                  = "${local.hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
    disk_size_gb          = 1024
  }

}

resource "azurerm_managed_disk" "mccloudux_datadisk" {
  count                = var.mccloudux_nb_instances
  name                 = "${local.hostname}-datadisk-${format("%02d",count.index)}"
  location             = var.resource_group_location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
}

resource "azurerm_virtual_machine_data_disk_attachment" "mccloudux_datadisk_attachement" {
  count              = var.mccloudux_nb_instances
  managed_disk_id    = azurerm_managed_disk.mccloudux_datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.mccloudux_vm[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "mccloudux_extension" {
  count                 = var.mccloudux_nb_instances
  name                  = "mccloudux"
  virtual_machine_id    = azurerm_linux_virtual_machine.mccloudux_vm[count.index].id
  publisher             = "Microsoft.Azure.Extensions"
  type                  = "CustomScript"
  type_handler_version  = "2.0"
  depends_on            = [azurerm_virtual_machine_data_disk_attachment.mccloudux_datadisk_attachement]

  settings = <<SETTINGS
    {
    "script": "IyEvYmluL2Jhc2gKY3AgL2V0Yy9yYy5kL3JjLmxvY2FsIC9ldGMvcmMuZC9yYy5sb2NhbC5iYWsKY2htb2QgK3ggL2V0Yy9yYy5kL3JjLmxvY2FsCmVjaG8gJ1Blcm1pdFJvb3RMb2dpbiB5ZXMnID4+IC9ldGMvc3NoL3NzaGRfY29uZmlnCmVjaG8gJ3hmc19ncm93ZnMgL2Rldi9zZGEyJyA+PiAvZXRjL3JjLmQvcmMubG9jYWwKZWNobyAnbXYgLWYgL2V0Yy9yYy5kL3JjLmxvY2FsLmJhayAvZXRjL3JjLmQvcmMubG9jYWwnID4+IC9ldGMvcmMuZC9yYy5sb2NhbAplY2hvIC1lICJkXG5cbm5cblxuXG5cblxudyIgfCBmZGlzayAvZGV2L3NkYQpzaHV0ZG93biAtcgo="
    }
  SETTINGS
}
