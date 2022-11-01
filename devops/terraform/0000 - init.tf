provider "azurerm" {
  features {}
}

# Custom tags 
variable "tags" {
  type      = map(string)
  default   = {}
}

##########
# Locals #
##########

locals { 
  # Merge Custom Tags with preset tags
  tags = merge(
    var.tags,
    {
      customer : "POC"
      project : "MONITORING"
    }
  )

  environment_suffix = "prd"
  
  #Base64 fromt he generated CA for tests...
  #openssl x509 -in caCert.pem -outform der | base64
  vpn_ca_cert = <<EOF
PAST KEY HERE
EOF
}
