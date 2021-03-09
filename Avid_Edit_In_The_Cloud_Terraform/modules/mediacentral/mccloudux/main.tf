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
    name                  = "${local.hostname}${format("%02d",count.index)}-osdisk"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
    disk_size_gb          = 1024
  }

}

resource "azurerm_managed_disk" "mccloudux_datadisk" {
  count                = var.mccloudux_nb_instances
  name                 = "${local.hostname}${format("%02d",count.index)}-datadisk"
  location             = var.resource_group_location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
}

resource "azurerm_virtual_machine_data_disk_attachment" "mccloudux_datadisk_attachement" {
  count              = var.nexis_storage_nb_instances
  managed_disk_id    = azurerm_managed_disk.nexis_datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.nexis_vm[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}
