provider "azurerm" {
}

module "azure" {
  source           = "../"
  
# ----------------------------------------
# Globals
# ----------------------------------------
   owner                      = "jhaug"
   resource_name              = "central" # This is NOT the resource group name, but is used to form the resource group name unless it is passed in as multi-region-resource-group-name
   multi_region               = false
   
# ----------------------------------------
# My IP Address - security group config
# ----------------------------------------
   my_ip_address              = "174.141.204.193"
# ----------------------------------------
# Allow non-TLS connections
# ----------------------------------------
  allow_non_tls              = true
   
#  file location for larger files not to be placed in the user home directory
#  will be created as root but owned by the adminuser on app-node and crdb-nodes
#  will hold application log files, cockraoch_data, and other large files.  Subdirectories
#  will be used from this location.  this crdb_file_location will be the mount point.  the first subdirectory will be the adminuser 
   crdb_file_location         = "/mnt/data"
# Azure Locations: "australiacentral,australiacentral2,australiaeast,australiasoutheast,brazilsouth,brazilsoutheast,brazilus,canadacentral,canadaeast,centralindia,centralus,centraluseuap,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,israelcentral,italynorth,japaneast,japanwest,jioindiacentral,jioindiawest,koreacentral,koreasouth,malaysiasouth,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southeastasia,southindia,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,austriaeast,chilecentral,eastusslv,israelnorthwest,malaysiawest,mexicocentral,newzealandnorth,southeastasiafoundational,spaincentral,taiwannorth,taiwannorthwest"
# ----------------------------------------
# Resource Group
# ----------------------------------------
   resource_group_location    = "centralus"
   
# ----------------------------------------
# Existing Key Info
# ----------------------------------------
   azure_ssh_key_name           = "jhaugland-centralus"
   azure_ssh_key_resource_group = "jhaugland-key-central-us"
   ssh_private_key              = "~/.ssh/jhaugland-centralus.pem"
   
# ----------------------------------------
# Network
# ----------------------------------------
   virtual_network_cidr       = "192.168.2.0/24"
   virtual_network_location   = "centralus"
   
# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
#   this is very small node just for testing deployment
#   crdb_vm_size               = "Standard_B4ms"
#   this is a medium size  production node
   crdb_vm_size               = "Standard_D8s_v5"
#   crdb_vm_size               = "Standard_D32s_v5"
   crdb_disk_size             = 1024
   crdb_store_disk_size             = 1024
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
   crdb_version               = "24.3.0-rc.1"

# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
# Be sure to do the following in your environment if you plan on installing the license keys
# must add the enterprise licence and the cluster organization to specified subdirectory
#  ${full_path_license_directory}/enterprise_licence
#  ${full_path_license_directory}/cluster_organization
   install_enterprise_keys   = "false"
   full_path_license_directory = "/Users/jasonhaugland/.crdb/"

# ----------------------------------------
# HA Proxy Instance Specifications
# ----------------------------------------
#   ha_proxy node will be created regardless of this flag
#       because the ha_proxy node also gets prometheus installed
#  very small size just to verify functionality
   haproxy_vm_size            = "Standard_B4ms"
#   haproxy_vm_size            = "Standard_D4s_v5"

# ----------------------------------------
# Create Network load balancer
# ----------------------------------------
#  if this is set to yes the load balancer will be used instead of haproxy
#     for the connections to the database.  However, haproxy will still be setup
#     unless the include_ha_proxy flag is set to no
   include_load_balancer           = "yes"


# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
   include_app                = "yes"
   start_replicator           = "no"
   app_nodes                  = 1
#   this is bare minimum for functionalizy
   app_vm_size                = "Standard_B4ms"
#   app_vm_size                = "Standard_D8s_v5"
   app_disk_size              = 64

# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
   include_kafka           = "no"
#   small size version
   kafka_vm_size            = "Standard_B4ms"
#    kafka_vm_size             = "Standard_D4s_v5"

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
