#Firewall Subnet
resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet" #required name! Do not change it!
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.2.0/24"]
}

#The IP we are going to use for our Firewall
#For now we cannot deploy an Azure Firewall without a Public IP over terraform
# https://github.com/hashicorp/terraform-provider-azurerm/issues/14055
resource "azurerm_public_ip" "firewallIp" {
  name                = "firewall-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.tags
}

# The Firewall policy we want to attach to our firewall
resource "azurerm_firewall_policy" "firewallPolicy" {
  name                = "firewall-policy"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

#The Firewall itself
resource "azurerm_firewall" "ps2firewalll" {
  name                = "ps2-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.firewallPolicy.id #linking it to the policy from above

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id #deploying it to the subnet defined above
    public_ip_address_id = azurerm_public_ip.firewallIp.id
  }

  depends_on = [
    azurerm_subnet.AzureFirewallSubnet
  ]
}
  