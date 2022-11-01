# This will enable traffic from p2s client to the local network, over the firewall
resource "azurerm_route_table" "p2s2Cloud" {
  name                        = "p2s-2-cloud"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name

  route {
    name                      = "ps2-2-cloud"
    address_prefix            = azurerm_subnet.cloudSubnet.address_prefixes[0] # destination is the cloud subnet
    next_hop_type             = "VirtualAppliance"
    next_hop_in_ip_address    = azurerm_firewall.ps2firewalll.ip_configuration[0].private_ip_address # via our deployed firewall
  }

  tags                        = local.tags
  #Lets create it after the gateway & firewall
  depends_on = [
    azurerm_virtual_network_gateway.main,
    azurerm_firewall.ps2firewalll
  ]
}
#Then we associate to the gateway subnet
resource "azurerm_subnet_route_table_association" "p2s2Cloud" {
  subnet_id      = azurerm_subnet.gatewaySubnet.id
  route_table_id = azurerm_route_table.p2s2Cloud.id
}

# This will enable traffic from local(in Azure) to the ps2 network, over the firewall
resource "azurerm_route_table" "cloud2p2s" {
  name                        = "cloud-2-p2s"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name

  route {
    name                      = "cloud-2-p2s"
    address_prefix            = azurerm_virtual_network_gateway.main.vpn_client_configuration[0].address_space[0] # destination is the address space from our p2s network 
    next_hop_type             = "VirtualAppliance"
    next_hop_in_ip_address    = azurerm_firewall.ps2firewalll.ip_configuration[0].private_ip_address # via our deployed firewall
  }
  tags                        = local.tags
  #Lets create it after the gateway & firewall
  depends_on = [
    azurerm_virtual_network_gateway.main,
    azurerm_firewall.ps2firewalll
  ]
}
#Then we associate to the cloud subnet
resource "azurerm_subnet_route_table_association" "cloud2p2s" {
  subnet_id      = azurerm_subnet.cloudSubnet.id
  route_table_id = azurerm_route_table.cloud2p2s.id
}
