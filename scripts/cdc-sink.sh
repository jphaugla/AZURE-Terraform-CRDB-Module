# tgt haproxy must be external on target
export TGT_HAPROXY=172.212.169.110
export URL_REQUIRE="postgresql://root:jasonrocks@${TGT_HAPROXY}:26257/ycsb?sslmode=require"
nohup cdc-sink  start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100 --foreignKeys > /tmp/cdc-sink.out 2>&1  &
