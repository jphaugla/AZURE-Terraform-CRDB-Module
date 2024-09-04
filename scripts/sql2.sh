# this is Haproxy on the target region so it must be public
export TGT_HAPROXY=52.184.153.153
export PASSWORD=jasonrocks
export DBUSER=jhaugland
export URL_REQUIRE="postgresql://${DBUSER}:${PASSWORD}@${TGT_HAPROXY}:26257/movr?sslmode=require"
export URL="postgresql://${DBUSER}@${TGT_HAPROXY}:26257/?sslmode=require&sslrootcert=target-certs/ca.crt&sslcert=target-certs/client.${DBUSER}.crt&sslkey=target-certs/client.${DBUSER}.key"
cockroach sql --url=${URL}
