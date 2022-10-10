resource "azurerm_resource_group" "main" {
  name     = "p2s-vpn-${local.environment_suffix}"
  location = "West Europe"
  tags     = local.tags
}