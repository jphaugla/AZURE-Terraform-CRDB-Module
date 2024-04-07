provider "azurerm" {
}

module "azure" {
  source           = "../"
  
# ----------------------------------------
# Globals
# ----------------------------------------
   owner                      = "jhaug"
   resource_name              = "east" # This is NOT the resource group name, but is used to form the resource group name unless it is passed in as multi-region-resource-group-name
   multi_region               = false
   
# ----------------------------------------
# My IP Address - security group config
# ----------------------------------------
   my_ip_address              = "104.201.89.194"
   
# Azure Locations: "australiacentral,australiacentral2,australiaeast,australiasoutheast,brazilsouth,brazilsoutheast,brazilus,canadacentral,canadaeast,centralindia,centralus,centraluseuap,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,israelcentral,italynorth,japaneast,japanwest,jioindiacentral,jioindiawest,koreacentral,koreasouth,malaysiasouth,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southeastasia,southindia,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,austriaeast,chilecentral,eastusslv,israelnorthwest,malaysiawest,mexicocentral,newzealandnorth,southeastasiafoundational,spaincentral,taiwannorth,taiwannorthwest"
# ----------------------------------------
# Resource Group
# ----------------------------------------
   resource_group_location    = "eastus2"
   
# ----------------------------------------
# Existing Key Info
# ----------------------------------------
   azure_ssh_key_name           = "jhaugland-eastus2"
   azure_ssh_key_resource_group = "jhaugland-rg"
   ssh_private_key              = "~/.ssh/jhaugland-eastus2.pem"
   
# ----------------------------------------
# Network
# ----------------------------------------
   virtual_network_cidr       = "192.168.3.0/24"
   virtual_network_location   = "eastus2"
   
# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
   crdb_vm_size               = "Standard_B2ms"
   crdb_disk_size             = 128
   crdb_resize_homelv         = "yes"
   crdb_nodes                 = 3
   
# ----------------------------------------
# CRDB Admin User - Cert Connection
# ----------------------------------------
   create_admin_user          = "yes"
   admin_user_name            = "jhaugland"
   admin_user_password        = "jasonrocks"
   
# ----------------------------------------
# CRDB Specifications
# ----------------------------------------
   crdb_version               = "23.2.3"
   
# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
# Be sure to do the following in your environment if you plan on installing the license keys
#   export TF_VAR_cluster_organization='your cluster organization'
#   export TF_VAR_enterprise_license='your enterprise license'
   install_enterprise_keys   = "yes"
   
# ----------------------------------------
# HA Proxy Instance Specifications
# ----------------------------------------
   include_ha_proxy           = "yes"
   haproxy_vm_size            = "Standard_B1ms"
   
# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
   include_app                = "yes"
   app_nodes                  = 1
   app_vm_size                = "Standard_B2ms"
   app_disk_size              = 64
   app_resize_homelv          = "no"  # if the app_disk_size is greater than 64, then set this to "yes" so that the disk will be resized.  See warnings in vars.tf!
   
# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
   include_kafka           = "no"
   kafka_vm_size            = "Standard_B4ms"
   
# ----------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
   install_system_location_data = "yes"
   
# ----------------------------------------
# Ansible variables
# ----------------------------------------
   instances_inventory_file = "inventory"
   ansible_verbosity_switch = ""
   
# ----------------------------------------
# Image parameters for Kafka
# ----------------------------------------
   test-publisher = "Canonical"
   test-offer     = "0001-com-ubuntu-server-jammy"
   test-sku       = "22_04-lts-gen2"
   test-version   = "latest"
}
