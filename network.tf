locals {
  subnet_list = cidrsubnets(var.virtual_network_cidr,3,3,3,3,3,3)
  private_subnet_list = chunklist(local.subnet_list,3)[0]
  public_subnet_list  = chunklist(local.subnet_list,3)[1]
}


resource "azurerm_virtual_network" "vm01" {
  name                = "${var.owner}-${var.resource_name}-network"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  address_space       = [var.virtual_network_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "sn" {
  count                = 3
  name                 = "${var.owner}-${var.resource_name}-subnet-${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vm01.name
  address_prefixes     = [local.public_subnet_list[count.index]]
  # tags are not a valid argument for subnets
}

resource "azurerm_network_security_group" "sg" {
    name                = "${var.owner}-${var.resource_name}-sg"
    location            = var.virtual_network_location
    resource_group_name = local.resource_group_name
    tags                = local.tags
}

resource "azurerm_network_security_rule" "desk-ssh" {
        name                       = "Desktop-TO-CRDB"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "${var.my_ip_address}/32"
        source_port_range          = "*"
        destination_port_ranges    = [22,26257,3000,8080,8081,8082,8083,8088,9021,9090,9092,9093,2181]
        destination_address_prefix = "*"
        resource_group_name        = local.resource_group_name
	network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "sink-webhook" {
        name                       = "cdc-sink-webhook"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_port_ranges    = [30004]
        destination_address_prefix = "*"
        resource_group_name        = local.resource_group_name
	network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_subnet_network_security_group_association" "desktop-access" {
  count                     = 3
  subnet_id                 = azurerm_subnet.sn[count.index].id
  network_security_group_id = azurerm_network_security_group.sg.id
}
