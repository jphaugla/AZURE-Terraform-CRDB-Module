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
   my_ip_address              = "174.141.204.193"
   
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
#   this is very small node just for testing deployment
#   crdb_vm_size               = "Standard_B2ms"
#   this is a medium size  production node 
   crdb_vm_size               = "Standard_D8s_v5"
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
   crdb_version               = "23.2.4"
   
# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
# Be sure to do the following in your environment if you plan on installing the license keys
# must add the enterprise licence and the cluster organization to the following subdirectory 
#  ../provisioners/temp/<region>/enterprise_licence
#  ../provisioners/temp/<region>/cluster_organization
   install_enterprise_keys   = "yes"
   
# ----------------------------------------
# HA Proxy Instance Specifications
# ----------------------------------------
   include_ha_proxy           = "yes"
#  very small size just to verify functionality
#   haproxy_vm_size            = "Standard_B2ms"
   haproxy_vm_size            = "Standard_D4s_v5"
   
# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
   include_app                = "yes"
   include_cdc_sink           = "no"
   app_nodes                  = 1
#   this is bare minimum for functionalizy
#   app_vm_size                = "Standard_B2ms"
   app_vm_size                = "Standard_D8s_v5"
   app_disk_size              = 64
   app_resize_homelv          = "no"  # if the app_disk_size is greater than 64, then set this to "yes" so that the disk will be resized.  See warnings in vars.tf!
   
# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
   include_kafka           = "no"
#   small size version
#   kafka_vm_size            = "Standard_B4ms"
   kafka_vm_size             = "Standard_D4s_v5"
   
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
