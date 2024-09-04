export DBUSER=jhaugland
export CONNECT='postgresql://${DBUSER}@52.184.153.153:26257?sslmode=verify-full&sslrootcert=/home/adminuser/certs/ca.crt&sslcert=/home/adminuser/certs/client.${DBUSER}.crt&sslkey=/home/adminuser/certs/client.${DBUSER}.key'
# cockroach workload init kv --drop --splits 338 ${CONNECT}
# max-rate max-ops
# max_rate did not help
#  max-ops just stops when it hits that number
# cockroach workload run  kv --concurrency=200 ${CONNECT}
cockroach workload run kv --concurrency=100 --max-rate=25000 ${CONNECT}
