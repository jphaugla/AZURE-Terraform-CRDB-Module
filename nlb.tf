# Public IP for Load Balancer
resource "azurerm_public_ip" "load_balancer_ip" {
  count = var.include_load_balancer == "yes" ? 1 : 0
  name        = "${var.owner}-${var.resource_name}-public-ip-load-balancer"
  location    = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method = "Static"
  sku         = "Standard"
  tags        = local.tags
}

# Load Balancer Resources (conditionally created)
resource "azurerm_lb" "private_load_balancer" {
  count = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-private-load-balancer"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "private_frontend"
    subnet_id                     = azurerm_subnet.sn[0].id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [azurerm_subnet.sn]
}

resource "azurerm_lb" "public_load_balancer" {
  count = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-load-balancer"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "public_frontend"
    public_ip_address_id = azurerm_public_ip.load_balancer_ip[0].id
  }
}

# Backend Pools
resource "azurerm_lb_backend_address_pool" "crdb_private_pool" {
  count            = var.include_load_balancer == "yes" ? 1 : 0
  name             = "${var.owner}-${var.resource_name}-crdb-private-backend-pool"
  loadbalancer_id  = azurerm_lb.private_load_balancer[0].id
}

resource "azurerm_lb_backend_address_pool" "crdb_public_pool" {
  count            = var.include_load_balancer == "yes" ? 1 : 0
  name             = "${var.owner}-${var.resource_name}-crdb-public-backend-pool"
  loadbalancer_id  = azurerm_lb.public_load_balancer[0].id
}

# Probes
resource "azurerm_lb_probe" "private_crdb_probe" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-private-crdb-probe"
  loadbalancer_id     = azurerm_lb.private_load_balancer[0].id
  port                = 8080
  interval_in_seconds = 5
  protocol            = "Http"
  request_path        = "/health?ready=1"
}

resource "azurerm_lb_probe" "public_crdb_probe" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-crdb-probe"
  loadbalancer_id     = azurerm_lb.public_load_balancer[0].id
  port                = 8080
  interval_in_seconds = 5
  protocol            = "Http"
  request_path        = "/health?ready=1"
}

# Rules
resource "azurerm_lb_rule" "private_admin_rule" {
  count                        = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id              = azurerm_lb.private_load_balancer[0].id
  name                         = "${var.owner}-${var.resource_name}-priv-admin-rule"
  protocol                     = "Tcp"
  frontend_port                = 8080
  backend_port                 = 8080
  frontend_ip_configuration_name = "private_frontend"
  backend_address_pool_ids     = [azurerm_lb_backend_address_pool.crdb_private_pool[0].id]
  probe_id                     = azurerm_lb_probe.private_crdb_probe[0].id
}

resource "azurerm_lb_rule" "public_admin_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.public_load_balancer[0].id
  name                 = "${var.owner}-${var.resource_name}-pub-admin-rule"
  protocol                 = "Tcp"
  frontend_port            = 8080  # Adjust port if CRDB service uses a different port
  backend_port             = 8080    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_public_pool[0].id]
  probe_id                = azurerm_lb_probe.public_crdb_probe[0].id
}

resource "azurerm_lb_rule" "public_crdb_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.public_load_balancer[0].id
  name                 = "${var.owner}-${var.resource_name}-pub-crdb-rule"
  protocol                 = "Tcp"
  frontend_port            = 26257  # Adjust port if CRDB service uses a different port
  backend_port             = 26257    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_public_pool[0].id]
  probe_id                = azurerm_lb_probe.public_crdb_probe[0].id
}

resource "azurerm_lb_rule" "private_crdb_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.private_load_balancer[0].id
  name                 = "${var.owner}-${var.resource_name}-priv-crdb-rule"
  protocol                 = "Tcp"
  frontend_port            = 26257  # Adjust port if CRDB service uses a different port
  backend_port             = 26257    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "private_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_private_pool[0].id]
  probe_id                = azurerm_lb_probe.private_crdb_probe[0].id
}
# Associate NIC with the private backend pool
resource "azurerm_network_interface_backend_address_pool_association" "crdb_private_pool_association" {
  count                    = var.crdb_nodes
  ip_configuration_name    = "staticconfigured"
  network_interface_id     = azurerm_network_interface.crdb_network_interface[count.index].id
  backend_address_pool_id  = azurerm_lb_backend_address_pool.crdb_private_pool[0].id
  depends_on = [
    azurerm_network_interface.crdb_network_interface,
    azurerm_lb_backend_address_pool.crdb_private_pool
  ]
}

# Associate NIC with the public backend pool
resource "azurerm_network_interface_backend_address_pool_association" "crdb_public_pool_association" {
  ip_configuration_name    = "staticconfigured"
  count                    = var.crdb_nodes
  network_interface_id     = azurerm_network_interface.crdb_network_interface[count.index].id
  backend_address_pool_id  = azurerm_lb_backend_address_pool.crdb_public_pool[0].id
  depends_on = [
    azurerm_network_interface.crdb_network_interface,
    azurerm_lb_backend_address_pool.crdb_public_pool
  ]
}
