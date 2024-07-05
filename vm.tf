resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "jakkavmnic-${count.index}"
  location            = azurerm_lb.lb.location
  resource_group_name = azurerm_lb.lb.resource_group_name

  ip_configuration {
    name                          = "jakkavmconfig-${count.index}"
    subnet_id                     = data.azurerm_subnet.snet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "disk" {
  count                = 2
  name                 = "datadisk-${count.index}"
  location             = azurerm_lb.lb.location
  resource_group_name  = azurerm_lb.lb.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

resource "azurerm_availability_set" "avset" {
  name                = "jakka-avset"
  location            = azurerm_lb.lb.location
  resource_group_name = azurerm_lb.lb.resource_group_name
}

resource "azurerm_virtual_machine" "vm" {
  count                 = 2
  name                  = "jakkavm-${count.index}"
  location              = azurerm_lb.lb.location
  resource_group_name   = azurerm_lb.lb.resource_group_name
  availability_set_id   = azurerm_availability_set.avset.id
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_data_disk {
    name              = element(azurerm_managed_disk.disk.*.name, count.index)
    managed_disk_type = element(azurerm_managed_disk.disk.*.id, count.index)
    create_option     = "Attach"
    lun               = 1
    disk_size_gb      = element(azurerm_managed_disk.disk.*.disk_size_gb, count.index)
  }
  os_profile {
    computer_name  = "jakkavm-${count.index}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = local.tags
}