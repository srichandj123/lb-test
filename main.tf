module "rg-lb" {
  source  = "app.terraform.io/jakka/rg/module"
  version = "3.1.1"
  loc     = "Central US"
  rg_name = "lb-rg"
  tags    = local.tags
}

resource "azurerm_public_ip" "pip" {
  name                = "lbpip"
  resource_group_name = module.rg-lb.rg_name
  location            = module.rg-lb.location
  allocation_method   = "Dynamic"
  tags                = local.tags
}
data "azurerm_subnet" "snet1" {
  name                 = "subnet-1"
  virtual_network_name = "VNET-1"
  resource_group_name  = "github-wkflow-rg"
}
resource "azurerm_lb" "lb" {

  name                = "jakkalb"
  location            = azurerm_public_ip.pip.location
  resource_group_name = azurerm_public_ip.pip.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name      = "PublicIPAddress"
    subnet_id = data.azurerm_subnet.snet1.id
  }
  tags = local.tags
}
resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "Backendpool"
  loadbalancer_id = azurerm_lb.lb.id
}
resource "azurerm_lb_nat_pool" "nat" {
  name                           = "ssh"
  resource_group_name            = azurerm_public_ip.pip.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "lb_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
  loadbalancer_id                = azurerm_lb.lb.id
}
resource "azurerm_lb_outbound_rule" "outrule" {
  name                    = "lboutrule"
  loadbalancer_id         = azurerm_lb.lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}