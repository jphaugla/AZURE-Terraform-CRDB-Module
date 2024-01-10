# AZURE-Terraform-CRDB-Module

![Resources Created in the Terraform HCL](resources/azure-single-regon.drawio.png)

Terraform HCL to create a multi-node CockroachDB cluster in Azure.   The number of nodes can be a multiple of 3 and nodes will be evenly distributed between 3 Azure Zones.   Optionally, you can include
 - haproxy VM - the proxy will be configured to connect to the cluster
 - app VM - application node that includes software for a multi-region demo

## Security Notes
- `firewalld` has been disabled on all nodes (cluster, haproxy and app).   
- A security group is created and assigned with ports 22, 8080 and 26257 opened to a single IP address.  The address is configurable as an input variable (my-ip-address)  

## Using the Terraform HCL
To use the HCL, you will need to define an Azure SSH Key -- that will be used for all VMs created to provide SSH access.

### Run this Terraform Script
```terraform
# See the appendix below to intall Terrafrom, the Azure CLI and logging in to Azure

git clone https://github.com/nollenr/AZURE-Terraform-CRDB-Module.git
cd AZURE-Terraform-CRDB-Module/
```

#### if you intend to use enterprise features of the database 
```
export TF_VAR_cluster_organization={CLUSTER ORG}
export TF_VAR_enterprise_license={LICENSE}
```


#### Modify the terraform.tfvars to meet your needs

```
terraform init
terraform plan
terraform apply
```
To clean up and remove everything that was created

```
terraform destroy
```

### terraform variable crdb_resize_homelv
In Azure, any additional space allocated to a disk beyond the size of the image, is available but unused.  Setting the variable `crdb_resize_homelv` to "yes", will cause the user_data script to attempt to resize the home logical volume to take advantage of the additional space.  This is potentially dangerous and should only be used if you're sure that sda2 is the volume group with the homelv partition.  Typically, if you're using the standard redhat source image defined in by the instance.tf you should be fine.  

## Appendix 
### Finding images
```
az vm image list -p "Canonical"
az vm image list -p "Microsoft"
```
### AZURE Terraform - CockroachDB on VM

#### Install Terrafrom
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

#### Install Azure CLI
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
for RHEL 8
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install azure-cli

az upgrade
az version
az login (directs you to a browser login with a code -- once authenticated, your credentials will be displayed in the terminal)

### Links:
Microsoft Terraform Docs
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform

Sizes for VM machines (not very helpful)
https://learn.microsoft.com/en-us/azure/virtual-machines/sizes

User Data that is a static SH 
https://github.com/guillermo-musumeci/terraform-azure-vm-bootstrapping-2/blob/master/linux-vm-main.tf

### Adding Kafka
Node internal and external addresses for haproxy, the app node, and kafka dumped as appropriately named text files in the directory [provisioners/temp](provisioners/temp)
### kafka node
Check out the kafka control panel by substituting the localhost with the ip found in [kafka_external_ip.txt](provisioners/temp/kafka_external_ip.txt) at http://localhost:9021

## Tech notes
* terraform.tfvars has the important parameters.  
* A template file at templates/inventory.tpl maps connects terraform to ansible along with provisioning.tf
* Ansible is all in the provisioners directory using the playbook.yml file
* Each of the node groups (haproxy-node, app-node, kafka-node) have a separate role under the provisioners/roles directory 
* Under each of these roles, a vars/main.yml file has variable flags to enable/disable processing
  * To eliminate all process on one of these node groups, best to set the node count to zero in terraform.tfvars
* Under each of these roles  a tasks/main.yml calls the required tasks to do the actual processing

To tear it all down:
NOTE:  on teardown, may see failures on delete of some azure components.  Re-running the destroy command will eventually be successful
```bash
terraform destroy
```
