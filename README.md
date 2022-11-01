# VPN
Base Terraform Template created based on:
https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal

Additionally, we added one vm to make it easier to test...

Firewall deployment similar to the one from this article:
https://cloudcurve.co.uk/azure/how-to-route-site-to-site-vpn-traffic-via-azure-firewall/


Here is the topology of this deployment:

![](devops/docs/topology.jpg?raw=true "Topology")

<span style="color:red">**This deployment takes about 35 minutes**</span>

# Basic Terraform Files description (devops/terraform folder):
 - 0000 - init
    - Tags, Environment Suffix and VPN CA Cert 
 - 0010 - resource-group-and-vnet
    - Resource Group and Net Deploymen, nichts besonders
 - 0020 - vpn-gateway
    - Gateway Subnet Deployment, Public IP and VPN Gateway
 - 0030 - firewall
    - Firewall Subnet, Firewall Public IP, Firewall Policy(Empty) and Firewall
 - 0040 - firewall-policy-rules
    - Firewall policies, enabling ICMP in Both Directions(p2s <-> cloud) and SSH (p2s -> cloud)
 - 0050 - route-tables
    - Routing Tables that forcing going over the firewall wenn coming from and to the cloud to ps2 net
 - 0060 - test-vm
    - Cloud Subnet and VM deployment for test purposes

# MACOs VPN Client Config

To config on MAC:
https://community.microstrategy.com/s/article/Set-up-point-to-site-VPN-in-Azure-for-Mac?language=en_US


1. Dependencies install
brew install strongswan
brew install openssl

2. Create CA Certificate
ipsec pki --gen --outform pem > caKey.pem
ipsec pki --self --in caKey.pem --dn "CN=VPN CA" --ca --outform pem > caCert.pem

3. add the output form this on the VPN Config as Root CA
 openssl x509 -in caCert.pem -outform der | base64

4. Create the client

export PASSWORD="123"
export USERNAME="polg"

ipsec pki --gen --outform pem > "${USERNAME}Key.pem"
ipsec pki --pub --in "${USERNAME}Key.pem" | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth --outform pem > "${USERNAME}Cert.pem"

openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"

