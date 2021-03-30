locals{
  #resource_group_name         = "${var.resource_prefix}-rg"
  #hostname                    = "${var.resource_prefix}-zbx"
}

data "azurerm_subnet" "data_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_public_ip" "zabbix_ip" {
  count               = var.zabbix_nb_instances
  name                = "${var.zabbix_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "zabbix_nic" {
  count                         = var.zabbix_nb_instances
  name                          = "${var.zabbix_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.data_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.zabbix_internet_access ? azurerm_public_ip.zabbix_ip[count.index].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "zabbix_vm" {
  count                         = var.zabbix_nb_instances
  name                          = "${var.zabbix_vm_hostname}-vm-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  size                          = var.zabbix_vm_size
  admin_username                = var.local_admin_username
  admin_password                = var.local_admin_password
  computer_name                 = "${var.zabbix_vm_hostname}-vm-${format("%02d",count.index)}"
  disable_password_authentication = false
  network_interface_ids         = [azurerm_network_interface.zabbix_nic[count.index].id]

 source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                  = "${var.zabbix_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
    disk_size_gb          = "1024"
  }

}
