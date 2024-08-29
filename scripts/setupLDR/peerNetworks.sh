vnetIdCentral=$(az network vnet show --resource-group jhaug-central-rg --name jhaug-central-network --query id --out tsv)
vnetIdEast=$(az network vnet show --resource-group jhaug-east-rg --name jhaug-east-network --query id --out tsv)
echo ${vnetIdCentral}
echo ${vnetIdEast}
az network vnet peering create --name jhaug-central-jhaug-east --resource-group jhaug-central-rg --vnet-name jhaug-central-network --remote-vnet ${vnetIdEast} --allow-vnet-access --allow-forwarded-traffic --verbose
az network vnet peering create --name jhaug-east-jhaug-central --resource-group jhaug-east-rg --vnet-name jhaug-east-network --remote-vnet ${vnetIdCentral} --allow-vnet-access --allow-forwarded-traffic --verbose
