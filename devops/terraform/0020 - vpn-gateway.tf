#This is the Subnet for the VPN Gateway
resource "azurerm_subnet" "gatewaySubnet" {
  name                 = "gatewaySubnet" #required name! Do not change it!
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.0.0/24"]
}

#The IP we are going to use for our VPN Gateway
resource "azurerm_public_ip" "gatewayIp" {
  name                = "vnet-gateway-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method   = "Dynamic"
  tags                = local.tags
}

#The VPN Gateway, configured for P2S Support
resource "azurerm_virtual_network_gateway" "main" {
  name                = "vnet-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
  type                = "Vpn"
  vpn_type            = "RouteBased"

  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gatewayIp.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaySubnet.id
  }

  vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "VPN-CA"

      public_cert_data = local.vpn_ca_cert
    }
  }
  #Lets create it after the firewall to avoid any concurrency issues
  depends_on = [
    azurerm_firewall.ps2firewalll,
    azurerm_subnet.gatewaySubnet
  ]
}
