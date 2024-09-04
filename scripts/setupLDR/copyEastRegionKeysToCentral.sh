#!/bin/zsh
COMMON_DIRECTORY=/Users/jasonhaugland/gits/AZURE-Terraform-CRDB-Module/provisioners/temp/
SOURCE_REGION=eastus2
SOURCE_KEY_DIRECTORY=${COMMON_DIRECTORY}/${SOURCE_REGION}
TARGET_REGION=centralus
TARGET_REGION_PEM=~/.ssh/jhaugland-${TARGET_REGION}.pem
TARGET_DIRECTORY=/home/adminuser/${SOURCE_REGION}_certs
# this is the only thing that needs to change
# this should be public IP in central for the CRDB nodes and the load balancer (haproxy)
target_nodes=(20.83.41.163 20.15.161.87 20.46.226.149)
for TARGET_NODE in ${target_nodes}; do
   echo "doing ${TARGET_NODE}"
   ssh -i ${TARGET_REGION_PEM} adminuser@${TARGET_NODE} "rm -rf ${TARGET_DIRECTORY}"
   ssh -i ${TARGET_REGION_PEM} adminuser@${TARGET_NODE} "mkdir -p ${TARGET_DIRECTORY}"
   scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_cert "adminuser@${TARGET_NODE}:${TARGET_DIRECTORY}/ca.crt"
   scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_user_cert "adminuser@${TARGET_NODE}:${TARGET_DIRECTORY}/client.jhaugland.crt"
   scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_user_key "adminuser@${TARGET_NODE}:${TARGET_DIRECTORY}/client.jhaugland.key"
   scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_public_key "adminuser@${TARGET_NODE}:${TARGET_DIRECTORY}/ca.pub"
done
