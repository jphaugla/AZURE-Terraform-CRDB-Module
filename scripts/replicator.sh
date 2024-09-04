# tgt haproxy must be external on target
export TGT_HAPROXY=172.212.169.110
export DBUSER=jhaugland
export DBPW=jasonrocks
export URL_REQUIRE="postgresql://${DBUSER}:${DBPW}@${TGT_HAPROXY}:26257/ycsb?sslmode=require"
nohup replicator  start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100 --foreignKeys > /tmp/replicator.out 2>&1  &
