resource "azurerm_resource_group" "main" {
  name     = "p2s-vpn-${local.environment_suffix}"
  location = "West Europe"
  tags     = local.tags
}

# The Cloud Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.tags
}