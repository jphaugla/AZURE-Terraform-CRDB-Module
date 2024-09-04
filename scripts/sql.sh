#  must modify this for correct IP addresses
export REGION=centralus
export DBUSER=jhaugland
export ROOT_TEMP=../provisioners/temp/${REGION}
echo root temp is ${ROOT_TEMP}
echo "get app node internal ip address, for creating change feed"
echo "get haproxy node external ip address, for creating change feed"
export HAPROXY_EXT=`cat ${ROOT_TEMP}/haproxy_external_ip.txt`
echo "HAPROXY EXT is ${HAPROXY_EXT}"
export APP_INT=`cat ${ROOT_TEMP}/app_internal_ip.txt`
echo "APP_INT is ${APP_INT}"
export URL="postgresql://root@${HAPROXY_EXT}:26257/?sslmode=verify-full&sslrootcert=${ROOT_TEMP}/ca.crt&sslcert=${ROOT_TEMP}/client.root.crt&sslkey=${ROOT_TEMP}/client.root.key"
export URLREQUIRE="postgresql://${DBUSER}@${HAPROXY_EXT}:26257/?sslmode=require"
echo ${URL}
# cockroach workload run movr $URL 
# cockroach sql --url "postgresql://root@${HAPROXY_EXT}:26257/?sslmode=verify-full&sslrootcert=${ROOT_TEMP}/ca.crt&sslcert=${ROOT_TEMP}/client.root.crt&sslkey=${ROOT_TEMP}/client.root.key"--execute "CREATE CHANGEFEED FOR TABLE movr.users,movr.vehicles,movr.rides,movr.vehicle_location_histories,movr.promo_codes,movr.user_promo_codes INTO 'webhook-https://${APP_INT}:30004/movr/public?insecure_tls_skip_verify=true' WITH updated, resolved='10s';"
cockroach sql --url $URLREQUIRE
