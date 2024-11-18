locals {
  app_zones = ["1", "2", "3"]
  prometheus_app_string = (var.prometheus_app_string != "" ? var.prometheus_app_string : join(",", formatlist("%s:30005", azurerm_network_interface.app[*].private_ip_address)))
}

resource "azurerm_public_ip" "app-ip" {
    count                        = var.app_nodes
    name                         = "${var.owner}-${var.resource_name}-public-ip-app-${count.index}"
    location                     = var.virtual_network_location
    resource_group_name          = local.resource_group_name
    allocation_method            = "Static"
    zones                        = [element(local.app_zones, count.index)]
    sku                          = "Standard"
    tags                         = local.tags
}

resource "azurerm_network_interface" "app" {
    count                       = var.app_nodes
    name                        = "${var.owner}-${var.resource_name}-ni-app-${count.index}"
    location                    = var.virtual_network_location
    resource_group_name         = local.resource_group_name
    tags                        = local.tags

    ip_configuration {
    name                          = "network-interface-app-ip-${count.index}"
    subnet_id                     = azurerm_subnet.sn[count.index%3].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app-ip[count.index].id
    }
}


resource "azurerm_linux_virtual_machine" "app" {
    count                 = var.include_app == "yes" ? var.app_nodes : 0
    name                  = "${var.owner}-${var.resource_name}-vm-app-${count.index}"
    location              = var.virtual_network_location
    resource_group_name   = local.resource_group_name
    size                  = var.app_vm_size
    zone		  = local.app_zones[count.index%3]
    tags                  = local.tags

    network_interface_ids = [azurerm_network_interface.app[count.index].id]

    admin_username                  = local.admin_username     # is this still required with an admin_ssh key block?
    disable_password_authentication = true
    admin_ssh_key {
        username                      = local.admin_username    # a bug in the provider requires this to be adminuser
        public_key                    = data.azurerm_ssh_public_key.ssh_key.public_key
    }

    source_image_reference {
        offer     = "RHEL"
        publisher = "RedHat"
        sku       = "90-gen2"
        version   = "latest"
    }

    # os_disk {
    #     name      = "${var.owner}-${var.resource_name}-osdisk-app"
    #     caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
    #     storage_account_type = "Standard_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
    # }
    os_disk {
        name      = "${var.owner}-${var.resource_name}-app-osdisk-${count.index}"
        caching   = "ReadWrite" # possible values: None, ReadOnly and ReadWrite
        storage_account_type = "Standard_LRS" # possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_SSD, StandardSSD_ZRS and Premium_ZRS
        disk_size_gb = var.app_disk_size
    }
    

    user_data = base64encode(<<EOF
#!/bin/bash -xe
echo "Shutting down and disabling firewalld -- SECURITY RISK!!"
systemctl stop firewalld
systemctl disable firewalld

echo "CRDB() {" >> /home/${local.admin_username}/.bashrc
echo 'cockroach sql --url "postgresql://${var.admin_user_name}@'"${azurerm_network_interface.haproxy[0].private_ip_address}:26257/defaultdb?sslmode=verify-full&sslrootcert="'$HOME/certs/ca.crt&sslcert=$HOME/certs/client.'"${var.admin_user_name}.crt&sslkey="'$HOME/certs/client.'"${var.admin_user_name}.key"'"' >> /home/${local.admin_username}/.bashrc
echo "}" >> /home/${local.admin_username}/.bashrc   
echo " " >> /home/${local.admin_username}/.bashrc   

echo "Installing and Configuring Demo Function"
echo "MULTIREGION_DEMO_INSTALL() {" >> /home/${local.admin_username}/.bashrc
echo "sudo yum install gcc -y" >> /home/${local.admin_username}/.bashrc
echo "sudo yum install gcc-c++ -y" >> /home/${local.admin_username}/.bashrc
echo "sudo yum install python36-devel -y" >> /home/${local.admin_username}/.bashrc
echo "sudo yum install libpq-devel -y" >> /home/${local.admin_username}/.bashrc

echo "sudo pip3 install sqlalchemy~=1.4" >> /home/${local.admin_username}/.bashrc
echo "sudo pip3 install sqlalchemy-cockroachdb" >> /home/${local.admin_username}/.bashrc
echo "sudo pip3 install psycopg2" >> /home/${local.admin_username}/.bashrc

echo "git clone https://github.com/jphaugla/Digital-Banking-CockroachDB.git"  >> /home/${local.admin_username}/.bashrc
echo "git clone https://github.com/nollenr/crdb-multi-region-demo.git" >> /home/${local.admin_username}/.bashrc
echo "echo 'DROP DATABASE IF EXISTS movr_demo;' > crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
echo "echo 'CREATE DATABASE movr_demo;' >> crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
echo "echo 'ALTER DATABASE movr_demo SET PRIMARY REGION = "\""${var.virtual_network_locations[0]}"\"";' >> crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
echo "echo 'ALTER DATABASE movr_demo ADD REGION "\""${element(var.virtual_network_locations,1)}"\"";' >> crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
echo "echo 'ALTER DATABASE movr_demo ADD REGION "\""${element(var.virtual_network_locations,2)}"\"";' >> crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
echo "echo 'ALTER DATABASE movr_demo SURVIVE REGION FAILURE;' >> crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc
if [[ '${var.virtual_network_locations[0]}' == '${var.virtual_network_location}' ]]; then echo "cockroach sql --url "\""postgres://${var.admin_user_name}@${azurerm_network_interface.haproxy[0].private_ip_address}:26257/defaultdb?sslmode=verify-full&sslrootcert=/home/${local.admin_username}/certs/ca.crt&sslcert=/home/${local.admin_username}/certs/client.${var.admin_user_name}.crt&sslkey=/home/${local.admin_username}/certs/client.${var.admin_user_name}.key"\"" --file crdb-multi-region-demo/sql/db_configure.sql" >> /home/${local.admin_username}/.bashrc; fi;
if [[ '${var.virtual_network_locations[0]}' == '${var.virtual_network_location}' ]]; then echo "cockroach sql --url "\""postgres://${var.admin_user_name}@${azurerm_network_interface.haproxy[0].private_ip_address}:26257/defaultdb?sslmode=verify-full&sslrootcert=/home/${local.admin_username}/certs/ca.crt&sslcert=/home/${local.admin_username}/certs/client.${var.admin_user_name}.crt&sslkey=/home/${local.admin_username}/certs/client.${var.admin_user_name}.key"\"" --file crdb-multi-region-demo/sql/import.sql" >> /home/${local.admin_username}/.bashrc; fi;
echo "}" >> /home/${local.admin_username}/.bashrc
echo "# For demo usage.  The python code expects these environment variables to be set" >> /home/${local.admin_username}/.bashrc
echo "export DB_HOST="\""${azurerm_network_interface.haproxy[0].private_ip_address}"\"" " >> /home/${local.admin_username}/.bashrc
echo "export DB_USER="\""${var.admin_user_name}"\"" " >> /home/${local.admin_username}/.bashrc
echo "export DB_SSLCERT="\""/home/${local.admin_username}/certs/client.${var.admin_user_name}.crt"\"" " >> /home/${local.admin_username}/.bashrc
echo "export DB_SSLKEY="\""/home/${local.admin_username}/certs/client.${var.admin_user_name}.key"\"" " >> /home/${local.admin_username}/.bashrc
echo "export DB_SSLROOTCERT="\""/home/${local.admin_username}/certs/ca.crt"\"" " >> /home/${local.admin_username}/.bashrc
echo "export DB_SSLMODE="\""require"\"" " >> /home/${local.admin_username}/.bashrc
if [[ '${var.include_demo}' == 'yes' ]]; then echo "Installing Demo"; sleep 60; su ${local.admin_username} -lc 'MULTIREGION_DEMO_INSTALL'; fi;

    EOF
    )
}
