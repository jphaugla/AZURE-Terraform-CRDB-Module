resource "azurerm_public_ip" "load_balancer-ip" {
  name        = "${var.owner}-${var.resource_name}-public-ip-load-balancer"
  location    = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method = "Static"
  sku         = "Standard"  # Ensure Standard SKU for backend address pool
  tags        = local.tags
}

resource "azurerm_public_ip" "network-interface-ip" {
  name        = "${var.owner}-${var.resource_name}-public-ip-network-interface"
  location    = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method = "Static"
  sku         = "Standard"
  tags        = local.tags
}

resource "azurerm_network_interface" "load_balancer_ni" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  name              = "${var.owner}-${var.resource_name}-ni-load-balancer"
  location          = var.virtual_network_location
  resource_group_name = local.resource_group_name
  tags              = local.tags
  ip_configuration {
    name                     = "${var.owner}-${var.resource_name}-load-balancer-ni-ip"
    subnet_id                 = azurerm_subnet.sn[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_rule" "private_admin_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.private_load_balancer.id
  name                 = "${var.owner}-${var.resource_name}-priv-admin-rule"
  protocol                 = "Tcp"
  frontend_port            = 8080  # Adjust port if CRDB service uses a different port
  backend_port             = 8080    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "private_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_private_pool.id]
  probe_id                = azurerm_lb_probe.private_crdb_probe.id
}
 
resource "azurerm_lb_rule" "private_crdb_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.private_load_balancer.id
  name                 = "${var.owner}-${var.resource_name}-priv-crdb-rule"
  protocol                 = "Tcp"
  frontend_port            = 26257  # Adjust port if CRDB service uses a different port
  backend_port             = 26257    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "private_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_private_pool.id]
  probe_id                = azurerm_lb_probe.private_crdb_probe.id
}
resource "azurerm_lb_rule" "public_admin_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.public_load_balancer.id
  name                 = "${var.owner}-${var.resource_name}-pub-admin-rule"
  protocol                 = "Tcp"
  frontend_port            = 8080  # Adjust port if CRDB service uses a different port
  backend_port             = 8080    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_public_pool.id]
  probe_id                = azurerm_lb_probe.public_crdb_probe.id
}
 
resource "azurerm_lb_rule" "public_crdb_rule" {
  count             = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id = azurerm_lb.public_load_balancer.id
  name                 = "${var.owner}-${var.resource_name}-pub-crdb-rule"
  protocol                 = "Tcp"
  frontend_port            = 26257  # Adjust port if CRDB service uses a different port
  backend_port             = 26257    # Adjust port if CRDB service uses a different port
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crdb_public_pool.id]
  probe_id                = azurerm_lb_probe.public_crdb_probe.id
}

resource "azurerm_lb_probe" "public_crdb_probe" {
  name                 = "${var.owner}-${var.resource_name}-public-crdb-probe"
  loadbalancer_id       = azurerm_lb.public_load_balancer.id
  port                 = 8080
  interval_in_seconds   = 5
  protocol              = "Http"
  request_path          = "/health?ready=1"
}

resource "azurerm_lb_probe" "private_crdb_probe" {
  name                 = "${var.owner}-${var.resource_name}-private-crdb-probe"
  loadbalancer_id       = azurerm_lb.private_load_balancer.id
  port                 = 8080
  interval_in_seconds   = 5
  protocol              = "Http"
  request_path          = "/health?ready=1"
}

resource "azurerm_lb_backend_address_pool" "crdb_private_pool" {
  name = "${var.owner}-${var.resource_name}-crdb-private-backend-pool"
  loadbalancer_id = azurerm_lb.private_load_balancer.id
}

resource "azurerm_lb_backend_address_pool" "crdb_public_pool" {
  name = "${var.owner}-${var.resource_name}-crdb-public-backend-pool"
  loadbalancer_id = azurerm_lb.public_load_balancer.id
}


resource "azurerm_network_interface_backend_address_pool_association" "backend_private_crdb" {
  count = length(azurerm_network_interface.crdb_network_interface)
  network_interface_id = azurerm_network_interface.crdb_network_interface[count.index].id
  ip_configuration_name = azurerm_network_interface.crdb_network_interface[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.crdb_private_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_public_crdb" {
  count = length(azurerm_network_interface.crdb_network_interface)
  network_interface_id = azurerm_network_interface.crdb_network_interface[count.index].id
  ip_configuration_name = azurerm_network_interface.crdb_network_interface[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.crdb_public_pool.id
}

resource "azurerm_lb" "private_load_balancer" {
  name                 = "${var.owner}-${var.resource_name}-private-load-balancer"
  location             = var.virtual_network_location
  resource_group_name  = local.resource_group_name
  sku                  = "Standard"  # Ensure Standard SKU for backend address pool
  frontend_ip_configuration {
    name                 = "private_frontend"
    subnet_id            = azurerm_subnet.sn[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "public_load_balancer" {
  name                 = "${var.owner}-${var.resource_name}-public-load-balancer"
  location             = var.virtual_network_location
  resource_group_name  = local.resource_group_name
  sku                  = "Standard"  # Ensure Standard SKU for backend address pool
  frontend_ip_configuration {
    name                 = "public_frontend"
    public_ip_address_id = azurerm_public_ip.load_balancer-ip.id
  }
}
