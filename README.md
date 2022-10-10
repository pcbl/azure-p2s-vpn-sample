# VPN
Base Terraform Template created based on:
https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal

Additionally, we added one vm to make it easier to test...


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
