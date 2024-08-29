# TODO:  CRDB instances greater than 3
locals {
  zones = ["1", "2", "3"]
  admin_username = "adminuser"
}

locals {
  ip_list     = join(" ", azurerm_network_interface.crdb_network_interface[*].private_ip_address)
  join_string = (var.join_string != "" ? var.join_string : join(",", azurerm_network_interface.crdb_network_interface[*].private_ip_address))
  prometheus_string = (var.prometheus_string != "" ? var.prometheus_string : join(",", formatlist("%s:8080", azurerm_network_interface.crdb_network_interface[*].private_ip_address)))
}

data "azurerm_ssh_public_key" "ssh_key" {
  name                = var.azure_ssh_key_name
  resource_group_name = var.azure_ssh_key_resource_group
}

resource "azurerm_public_ip" "crdb-ip" {
  count                        = var.crdb_nodes
  name                         = "${var.owner}-${var.resource_name}-public-ip-${count.index}"
  location                     = var.virtual_network_location
  resource_group_name          = local.resource_group_name
  allocation_method            = "Static"
  zones                        = [element(local.zones, count.index)]
  sku                          = "Standard"
  tags                         = local.tags
}

resource "azurerm_network_interface" "crdb_network_interface" {
  count                     = var.crdb_nodes
  name                      = "${var.owner}-${var.resource_name}-ni-${count.index}"
  location                  = var.virtual_network_location
  resource_group_name       = local.resource_group_name
  tags                      = local.tags

  ip_configuration {
    name                          = "${var.owner}-${var.resource_name}-ip-${count.index}"
    subnet_id                     = azurerm_subnet.sn[count.index%3].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.crdb-ip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "crdb-instance" {
  count                 = var.create_ec2_instances == "yes" ? var.crdb_nodes : 0
  name                  = "${var.owner}-${var.resource_name}-vm-crdb-${count.index}"
  location              = var.virtual_network_location
  resource_group_name   = local.resource_group_name
  size                  = var.crdb_vm_size
  tags                  = local.tags
  zone                  = local.zones[count.index%3]


  network_interface_ids = [azurerm_network_interface.crdb_network_interface[count.index].id]

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
    name      = "${var.owner}-${var.resource_name}-osdisk-${count.index}"
    caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
    storage_account_type = "Premium_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
    disk_size_gb = var.crdb_disk_size
  }

  # echo "export ip_local=\`curl -H Metadata:true --noproxy \"*\" \"http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text\"\`" >> /home/${local.admin_username}/.bashrc
  # echo "export azure_region=\`curl -s -H Metadata:true --noproxy \"*\" \"http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text\"\`" >> /home/${local.admin_username}/.bashrc

  user_data = base64encode(<<EOF
#!/bin/bash -xe
echo "Shutting down and disabling firewalld -- SECURITY RISK!!"
systemctl stop firewalld
systemctl disable firewalld
echo "Setting variables"
echo "export COCKROACH_CERTS_DIR=/home/${local.admin_username}/certs" >> /home/${local.admin_username}/.bashrc
echo 'export CLUSTER_PRIVATE_IP_LIST="${local.ip_list}" ' >> /home/${local.admin_username}/.bashrc
export CLUSTER_PRIVATE_IP_LIST="${local.ip_list}"
echo 'export JOIN_STRING="${local.join_string}" ' >> /home/${local.admin_username}/.bashrc
echo "export ip_local=${azurerm_network_interface.crdb_network_interface[count.index].private_ip_address}" >> /home/${local.admin_username}/.bashrc
echo "export ip_public=${azurerm_public_ip.crdb-ip[count.index].ip_address }" >> /home/${local.admin_username}/.bashrc
echo "export azure_region=${var.virtual_network_location}" >> /home/${local.admin_username}/.bashrc
echo "export azure_zone=\"${var.virtual_network_location}-${local.zones[count.index%3]}\"" >> /home/${local.admin_username}/.bashrc
echo "export CRDBNODE=${count.index}" >> /home/${local.admin_username}/.bashrc
export CRDBNODE=${count.index}
counter=1;for IP in $CLUSTER_PRIVATE_IP_LIST; do echo "export NODE$counter=$IP" >> /home/${local.admin_username}/.bashrc; (( counter++ )); done

echo "Creating the CREATENODECERT bashrc function"
echo "CREATENODECERT() {" >> /home/${local.admin_username}/.bashrc
echo "  cockroach cert create-node \\" >> /home/${local.admin_username}/.bashrc
echo '  $ip_local \' >> /home/${local.admin_username}/.bashrc
echo '  $ip_public \' >> /home/${local.admin_username}/.bashrc
echo "  localhost \\" >> /home/${local.admin_username}/.bashrc
echo "  127.0.0.1 \\" >> /home/${local.admin_username}/.bashrc
echo "Adding haproxy to the CREATENODECERT function if var.include_ha_proxy is yes"
if [ "${var.include_ha_proxy}" = "yes" ]; then echo "  ${azurerm_network_interface.haproxy[0].private_ip_address} \\" >> /home/${local.admin_username}/.bashrc; fi
echo "  --certs-dir=certs \\" >> /home/${local.admin_username}/.bashrc
echo "  --ca-key=my-safe-directory/ca.key" >> /home/${local.admin_username}/.bashrc
echo "}" >> /home/${local.admin_username}/.bashrc

echo "Creating the CREATEROOTCERT bashrc function"
echo "CREATEROOTCERT() {" >> /home/${local.admin_username}/.bashrc
echo "  cockroach cert create-client \\" >> /home/${local.admin_username}/.bashrc
echo '  root \' >> /home/${local.admin_username}/.bashrc
echo "  --certs-dir=certs \\" >> /home/${local.admin_username}/.bashrc
echo "  --ca-key=my-safe-directory/ca.key" >> /home/${local.admin_username}/.bashrc
echo "}" >> /home/${local.admin_username}/.bashrc   

echo "Creating the STARTCRDB bashrc function"
echo "STARTCRDB() {" >> /home/${local.admin_username}/.bashrc
echo "  cockroach start \\" >> /home/${local.admin_username}/.bashrc
echo '  --locality=region="$azure_region",zone="$azure_zone" \' >> /home/${local.admin_username}/.bashrc
echo "  --certs-dir=certs \\" >> /home/${local.admin_username}/.bashrc
echo '  --advertise-addr=$ip_local \' >> /home/${local.admin_username}/.bashrc
echo '  --join=$JOIN_STRING \' >> /home/${local.admin_username}/.bashrc
echo '  --max-offset=250ms \' >> /home/${local.admin_username}/.bashrc
echo "  --background " >> /home/${local.admin_username}/.bashrc
echo " }" >> /home/${local.admin_username}/.bashrc

echo "SETCRDBVARS() {" >> /home/${local.admin_username}/.bashrc
echo "  cockroach node status | awk -F ':' 'FNR > 1 { print \$1 }' | awk '{ print \$1, \$2 }' |  while read line; do" >> /home/${local.admin_username}/.bashrc
echo "    node_number=\`echo \$line | awk '{ print \$1 }'\`" >> /home/${local.admin_username}/.bashrc
echo "    variable_name=CRDBNODE\$node_number" >> /home/${local.admin_username}/.bashrc
echo "    ip=\`echo \$line | awk '{ print \$2 }'\`" >> /home/${local.admin_username}/.bashrc
echo "    echo export \$variable_name=\$ip >> crdb_node_list" >> /home/${local.admin_username}/.bashrc
echo "  done" >> /home/${local.admin_username}/.bashrc
echo "  source ./crdb_node_list" >> /home/${local.admin_username}/.bashrc
echo "}" >> /home/${local.admin_username}/.bashrc

  EOF
)
  
}
