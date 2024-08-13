COMMON_DIRECTORY=/Users/jasonhaugland/gits/AZURE-Terraform-CRDB-Module/provisioners/temp/
SOURCE_REGION=centralus
SOURCE_KEY_DIRECTORY=${COMMON_DIRECTORY}/${SOURCE_REGION}
TARGET_REGION=eastus2
TARGET_REGION_PEM=~/.ssh/jhaugland-${TARGET_REGION}.pem
TARGET_DIRECTORY=/home/adminuser/${SOURCE_REGION}_certs
# this should be public CRDB IP in eastus2 in this case
TARGET_CRDB_NODE=172.210.193.204
ssh -i ${TARGET_REGION_PEM} adminuser@${TARGET_CRDB_NODE} "rm -rf ${TARGET_DIRECTORY}"
ssh -i ${TARGET_REGION_PEM} adminuser@${TARGET_CRDB_NODE} "mkdir -p ${TARGET_DIRECTORY}"
scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_cert "adminuser@${TARGET_CRDB_NODE}:${TARGET_DIRECTORY}/ca.crt"
scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_user_cert "adminuser@${TARGET_CRDB_NODE}:${TARGET_DIRECTORY}/client.jhaugland.crt"
scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_user_key "adminuser@${TARGET_CRDB_NODE}:${TARGET_DIRECTORY}/client.jhaugland.crt"
scp -i ${TARGET_REGION_PEM} $SOURCE_KEY_DIRECTORY/tls_public_key "adminuser@${TARGET_CRDB_NODE}:${TARGET_DIRECTORY}/ca.pub"
