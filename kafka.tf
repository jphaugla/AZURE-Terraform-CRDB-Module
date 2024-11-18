resource "azurerm_public_ip" "kafka-ip" {
    count                      = var.include_kafka == "yes" ? 1 : 0
    name                         = "${var.owner}-${var.resource_name}-public-ip-kafka"
    location                     = var.virtual_network_location
    resource_group_name          = local.resource_group_name
    allocation_method            = "Dynamic"
    sku                          = "Basic"
    tags                         = local.tags
}

resource "azurerm_network_interface" "kafka" {
    count                       = var.include_kafka == "yes" ? 1 : 0
    name                      = "${var.owner}-${var.resource_name}-ni-kafka"
    location                  = var.virtual_network_location
    resource_group_name       = local.resource_group_name
    tags                      = local.tags

    ip_configuration {
        name                          = "network-interface-kafka-ip"
        subnet_id                     = azurerm_subnet.sn[0].id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.kafka-ip[0].id
    }
}

resource "azurerm_linux_virtual_machine" "kafka" {
    count                 = var.include_kafka == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
    name                  = "${var.owner}-${var.resource_name}-vm-kafka"
    location              = var.virtual_network_location
    resource_group_name   = local.resource_group_name
    size                  = var.kafka_vm_size
    tags                  = local.tags

    network_interface_ids = [azurerm_network_interface.kafka[0].id]

    admin_username                  = local.admin_username     # is this still required with an admin_ssh key block?
    disable_password_authentication = true
    admin_ssh_key {
        username                      = local.admin_username    # a bug in the provider requires this to be adminuser
        public_key                    = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    publisher = var.test-publisher
    offer     = var.test-offer
    sku       = var.test-sku
    version   = var.test-version
  }

  os_disk {
    # do I assume this disk is deleted when the vm is deleted?  
    name      = "${var.owner}-${var.resource_name}-osdisk-kafka"
    caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
    storage_account_type = "Standard_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
  }
}
