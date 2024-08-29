# Setup LDR between 2 clusters created by this github
## Note:  scripts will need to be individualy edited for particular regions used and IP addresses
## Overall Steps
* Peer the network between 2 independently created clusters
* Copy the tls keys from each cluster to the other cluster using provided scripts
* Need to have an additional columm on each table that is being replicated
* Need kv.rangefeed.enabled set to true on each cluster
* Need replication privilege for the user starting the replication stream
* create external connection
* create logical replication stream
* validate

## Detailed
### Peer the network between 2 independently created clusters
* Run the peerNetworks.sh script in this directory to peer the two networks
```bash
./peerNetworks.sh
```
### Copy the tls keys from each cluster to the other cluster using provided scripts
* Edit copyCentralRegionKeysToEast.sh and copyEastRegionKeysToCentral.sh to have the correct IPs as described in each script
  * IP addresses can be found by looking in the Azure UI or by looking at most recent files in ./provisioners/temp/<region name>
* execute both of the scripts to copy the keys
```bash
./copyCentralRegionKeysToEast.sh
./copyEastRegionKeysToCentral.sh
```
###  Need to have an additional columm on each table that is being replicated
This is part of the scripts provided on each of the application nodes in each cluster.
* For each region
  * log into the application node for the region
  * execute the kv-workload.sh script to create the kv-worklaod database and tables as well as alter the table to add the necessary column
```bash
ssh -i <pem file> adminuser@<public ip of app node>
./kv-workload.sh
```
###  Need kv.rangefeed.enabled set to true on each cluster
This is already taken care of in the ansible steps
###  Need replication privilege for the user starting the replication stream
This is already taken care of in the ansible steps
### create external connection
Use the provided scripts in this directory.  The sql scripts need to be edited as directed in each file
* files are: createExternalConnectionPullCentralFromEast.sh, createExternalConnectionPullCentralFromEast.sql, createExternalConnectionPullEastFromCentral.sh, createExternalConnectionPullEastFromCentral.sql
* files need to be copied to one of the CRDB nodes in the correct region
  * copy these two files to a CRDB node in the East Region:  createExternalConnectionPullCentralFromEast.sh, createExternalConnectionPullCentralFromEast.sql
  * copy these two files to a CRDB node in the Central Region:  createExternalConnectionPullEastFromCentral.sh, createExternalConnectionPullEastFromCentral.sql
* add execute permission to the shell script file on each node and run the shell script 
### create logical replication stream
This may not work correctly with the replication stream name.  If it doesn't work, substitute out the replication stream name with the pgURL in the script to create the external connection
Use the provided scripts in this directory.  
* files are: startReplicationPullCentralFromEast.sh, startReplicationPullCentralFromEast.sql, startReplicationPullEastFromCentral.sh, startReplicationPullEastFromCentral.sql
  * copy these two files to a CRDB node in the East Region:  startReplicationPullCentralFromEast.sh, startReplicationPullCentralFromEast.sql
  * copy these two files to a CRDB node in the Central Region:  startReplicationPullEastFromCentral.sh, startReplicationPullEastFromCentral.sql
### validate
should have the same number of records on each side
