#Cloud Vnet, where the VM will be
resource "azurerm_subnet" "cloudSubnet" {
  name                 = "cloudSubnet" 
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}

#The Network card, connected to our cloud subnet
resource "azurerm_network_interface" "vmNic" {
  name                = "test-vm-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cloudSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#And the test VM, just a small(Standard_B1ls) one to play arorund
resource "azurerm_linux_virtual_machine" "testVm" {
  name                = "test-vm"
  tags                = local.tags
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1ls"
  admin_username      = "gft"
  network_interface_ids = [
    azurerm_network_interface.vmNic.id,
  ]

  admin_ssh_key {
    username   = "gft"
    #taking my own public key. ;-)
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}