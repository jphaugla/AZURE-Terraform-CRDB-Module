resource "local_file" "instances_file" {
    filename = "${var.instances_inventory_directory}/${var.instances_inventory_file}"
    content = templatefile("${var.inventory_template_file}",
        {
            crdb_public_names = "${join("\n", (azurerm_public_ip.crdb-ip.*.name) )}"
            crdb_public_ips = "${join("\n", (azurerm_public_ip.crdb-ip.*.ip_address) )}"
            crdb_private_ips = "${join("\n", azurerm_network_interface.crdb_network_interface[*].private_ip_address)}"
            crdb_private_ip_0 = "${azurerm_network_interface.crdb_network_interface.0.private_ip_address}"
            crdb_public_ips_0 = "${azurerm_public_ip.crdb-ip.0.ip_address}"
            crdb_public_ips_rest = "${join("\n", slice( azurerm_public_ip.crdb-ip.*.ip_address, 1, length(azurerm_public_ip.crdb-ip.*.ip_address) ) )}"
            kafka_public_ip = length(azurerm_linux_virtual_machine.kafka) > 0 ? "${azurerm_linux_virtual_machine.kafka.0.public_ip_address}" : "null"
            kafka_private_ip = length(azurerm_linux_virtual_machine.kafka) > 0 ? "${azurerm_linux_virtual_machine.kafka.0.private_ip_address}" : "null"
            haproxy_public_ip = "${azurerm_linux_virtual_machine.haproxy.0.public_ip_address}"
            haproxy_private_ip = "${azurerm_linux_virtual_machine.haproxy.0.private_ip_address}"
            app_public_ip = "${azurerm_linux_virtual_machine.app.0.public_ip_address}"
            app_private_ip = "${azurerm_linux_virtual_machine.app.0.private_ip_address}"
            ssh_user = "${local.admin_username}"
            cluster_size = "${var.crdb_nodes}"
        })

    depends_on = [
        azurerm_public_ip.crdb-ip, azurerm_network_interface.kafka, azurerm_public_ip.kafka-ip
    ]
}
