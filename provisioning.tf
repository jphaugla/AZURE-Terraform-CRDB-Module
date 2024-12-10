# Locals
locals {
  kafka_private_ip       = var.include_kafka == "yes" ? azurerm_linux_virtual_machine.kafka[0].private_ip_address : "localhost"
  front_end_public_ip    = var.include_load_balancer == "yes" ? azurerm_public_ip.load_balancer_ip[0].ip_address : azurerm_linux_virtual_machine.haproxy[0].public_ip_address
  front_end_private_ip   = var.include_load_balancer == "yes" ? azurerm_lb.private_load_balancer[0].private_ip_address : azurerm_linux_virtual_machine.haproxy[0].private_ip_address
}

# Dummy Resource (fallback)
resource "null_resource" "dummy" {}

# Conditional Resource Dependencies
resource "null_resource" "lb_dependencies" {
  count = var.include_load_balancer == "yes" ? 1 : 0
  depends_on = [
    azurerm_lb.public_load_balancer,
    azurerm_lb.private_load_balancer
  ]
}

resource "null_resource" "validation_check" {
  count = (
    var.include_load_balancer == "yes" || var.include_ha_proxy == "yes" ? 0 : 1
  )

  provisioner "local-exec" {
    command = "echo 'Validation Error: Either include_load_balancer or include_ha_proxy must be set to yes.' && exit 1"
  }
}

# Null Resource for Provisioning
resource "null_resource" "provision" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/${var.instances_inventory_directory}"
    command     = "ansible-playbook -i '${var.instances_inventory_file}' --private-key ${var.ssh_private_key} playbook.yml ${var.ansible_verbosity_switch} -e 'db_admin_user=${var.admin_user_name}' -e 'db_admin_password=${var.admin_user_password}' -e 'crdb_version=${var.crdb_version}' -e 'region=${var.virtual_network_location}' -e 'include_kafka=${var.include_kafka}' -e 'start_replicator=${var.start_replicator}' -e 'kafka_internal_ip=${local.kafka_private_ip}' -e 'prometheus_string=${local.prometheus_string}' -e 'prometheus_app_string=${local.prometheus_app_string}' -e 'join_string=${local.join_string}' -e 'full_path_license_directory=${var.full_path_license_directory}' -e 'allow_non_tls=${var.allow_non_tls}' -e 'crdb_file_location=${var.crdb_file_location}' -e 'admin_username=${local.admin_username}' -e 'include_app=${var.include_app}' -e 'install_enterprise_keys=${var.install_enterprise_keys}' -e 'load_balancer_public_ip=${local.front_end_public_ip}' -e 'load_balancer_private_ip=${local.front_end_private_ip}'"
  }

  depends_on = [
    azurerm_public_ip.crdb-ip,
    local_file.instances_file,
    azurerm_network_interface.crdb_network_interface,
    azurerm_linux_virtual_machine.haproxy,
    azurerm_linux_virtual_machine.app,
    azurerm_linux_virtual_machine.kafka,
    azurerm_linux_virtual_machine.crdb-instance,
    null_resource.lb_dependencies,
    null_resource.dummy
  ]
}
