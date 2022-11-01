#Here we enable ICMP and SSH on the policy
resource "azurerm_firewall_policy_rule_collection_group" "policyCollection" {
  name               = "firewall-policy-collection"
  firewall_policy_id = azurerm_firewall_policy.firewallPolicy.id
  priority           = 500

  network_rule_collection {
    name     = "network_rule_collection"
    priority = 400
    action   = "Allow"

    rule {
      name = "icmp-cloud-2-p2s"

      source_addresses = azurerm_subnet.cloudSubnet.address_prefixes
      destination_ports = ["*"]
      destination_addresses = azurerm_virtual_network_gateway.main.vpn_client_configuration[0].address_space
      protocols = [
        "ICMP"
      ]
    }

    rule {
      name = "icmp-p2s-2-cloud"
      source_addresses = azurerm_virtual_network_gateway.main.vpn_client_configuration[0].address_space
      destination_ports = ["*"]
      destination_addresses =  azurerm_subnet.cloudSubnet.address_prefixes      
      protocols = [
        "ICMP"
      ]
    }

    rule {
      name = "ssh-p2s-2-cloud"
      source_addresses = azurerm_virtual_network_gateway.main.vpn_client_configuration[0].address_space
      destination_ports = ["22"]
      destination_addresses = azurerm_subnet.cloudSubnet.address_prefixes
      protocols = [
        "TCP"
      ]
    }
  }
}
