resource "azurerm_network_security_group" "nsg" {
  name                = "jakka-nsg"
  location            = azurerm_lb.lb.location
  resource_group_name = azurerm_lb.lb.resource_group_name
  dynamic "security_rule" {
    for_each = var.securityrules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}