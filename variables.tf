variable "securityrules" {
  type = map(object({
    name      = string
    priority  = number
    direction = string
  }))

  default = {
    "rule1" = {
      name                       = "test123"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"

    }
  }

}