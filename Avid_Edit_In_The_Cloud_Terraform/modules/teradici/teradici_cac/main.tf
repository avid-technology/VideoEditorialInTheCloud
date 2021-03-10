locals{
  #resource_group_name         = "${var.resource_prefix}-rg"
  #hostname                    = "${var.resource_prefix}-cac"
}

resource "azurerm_public_ip" "teradicicac_ip" {
  count               = var.teradicicac_internet_access ? var.teradicicac_nb_instances : 0
  #count               = var.teradicicac_nb_instances
  name                = "${var.teradicicac_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "teradicicac_nic" {
  count                         = var.teradicicac_nb_instances
  name                          = "${var.teradicicac_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  #enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.teradicicac_internet_access ? azurerm_public_ip.teradicicac_ip[count.index].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "teradicicac_vm" {
  count                             = var.teradicicac_nb_instances
  name                              = "${var.teradicicac_vm_hostname}-${format("%02d",count.index)}"
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  size                              = var.teradicicac_vm_size
  admin_username                    = var.local_admin_username
  #admin_password                   = var.local_admin_password
  computer_name                     = "${var.teradicicac_vm_hostname}-${format("%02d",count.index)}"
  disable_password_authentication   = true
  network_interface_ids             = [azurerm_network_interface.teradicicac_nic[count.index].id]

admin_ssh_key {
  username   = var.local_admin_username
  public_key = file("~/.ssh/id_rsa.pub")
  }

 source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                  = "${var.teradicicac_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
    disk_size_gb          = "1024"
  }

}
