resource "azurerm_public_ip" "haproxy-ip" {
    # count                      = var.include_ha_proxy == "yes" ? 1 : 0
    count                        = 1
    name                         = "${var.owner}-${var.resource_name}-public-ip-haproxy"
    location                     = var.virtual_network_location
    resource_group_name          = local.resource_group_name
    allocation_method            = "Dynamic"
    sku                          = "Basic"
    tags                         = local.tags
}

resource "azurerm_network_interface" "haproxy" {
    # count                       = var.include_ha_proxy == "yes" ? 1 : 0
    count                     = 1
    name                      = "${var.owner}-${var.resource_name}-ni-haproxy"
    location                  = var.virtual_network_location
    resource_group_name       = local.resource_group_name
    tags                      = local.tags

    ip_configuration {
        name                          = "network-interface-haproxy-ip"
        subnet_id                     = azurerm_subnet.sn[0].id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.haproxy-ip[0].id
    }
}

resource "azurerm_linux_virtual_machine" "haproxy" {
    count                 = var.include_ha_proxy == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
    name                  = "${var.owner}-${var.resource_name}-vm-haproxy"
    location              = var.virtual_network_location
    resource_group_name   = local.resource_group_name
    size                  = var.haproxy_vm_size
    tags                  = local.tags

    network_interface_ids = [azurerm_network_interface.haproxy[0].id]

    admin_username                  = local.admin_username     # is this still required with an admin_ssh key block?
    disable_password_authentication = true
    admin_ssh_key {
        username                      = local.admin_username    # a bug in the provider requires this to be adminuser
        public_key                    = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "9-lvm-gen2"
    version   = "latest"
  }

  os_disk {
    # do I assume this disk is deleted when the vm is deleted?  
    name      = "${var.owner}-${var.resource_name}-osdisk-haproxy"
    caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
    storage_account_type = "Standard_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
  }

}
