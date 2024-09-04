export DBUSER=jhaugland
export DBPW=jasonrocks
# this is Haproxy on the target region
export TGT_HAPROXY=40.83.35.248
export URL="postgresql://${DBUSER}@${TGT_HAPROXY}:26257/?sslmode=verify-full&ssl${DBUSER}cert=certs/ca.crt&sslcert=certs/client.${DBUSER}.crt&sslkey=certs/client.${DBUSER}.key"
export URL_REQUIRE="postgresql://${DBUSER}:${DWPW}@${TGT_HAPROXY}:26257/ycsb?sslmode=require"
replicator  start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100
# replicator -v start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100 --foreignKeys
