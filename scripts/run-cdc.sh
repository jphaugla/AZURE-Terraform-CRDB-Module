# this is Haproxy on the target region
export TGT_HAPROXY=40.83.35.248
export URL="postgresql://jhaugland@${TGT_HAPROXY}:26257/?sslmode=verify-full&ssljhauglandcert=certs/ca.crt&sslcert=certs/client.jhaugland.crt&sslkey=certs/client.jhaugland.key"
export URL_REQUIRE="postgresql://jhaugland:jasonrocks@${TGT_HAPROXY}:26257/ycsb?sslmode=require"
cdc-sink  start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100
# cdc-sink -v start --bindAddr :30004 --metricsAddr :30005 --tlsSelfSigned --disableAuthentication --targetConn $URL_REQUIRE  --selectBatchSize 100 --foreignKeys
