data "azurerm_resource_group" "class" {
  name = var.rg
}

resource "azurerm_storage_account" "mystorage" {
  name                     = var.storage
  resource_group_name      = data.azurerm_resource_group.class.name
  location                 = data.azurerm_resource_group.class.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_virtual_network" "network" {
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.class.location
  resource_group_name = data.azurerm_resource_group.class.name
}

resource "azurerm_subnet" "sub" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.class.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = var.nic
  location            = data.azurerm_resource_group.class.location
  resource_group_name = data.azurerm_resource_group.class.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm
  resource_group_name             = data.azurerm_resource_group.class.name
  location                        = data.azurerm_resource_group.class.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Adminazure$123"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
