#  must modify this for correct IP addresses
export REGION=eastus2
export DBUSER=jhaugland
export DBPW=jasonrocks
export ROOT_TEMP=../provisioners/temp/${REGION}
echo root temp is ${ROOT_TEMP}
echo "get app node internal ip address, for creating change feed"
echo "get haproxy node external ip address, for creating change feed"
export HAPROXY_EXT=`cat ${ROOT_TEMP}/haproxy_external_ip.txt`
echo "HAPROXY EXT is ${HAPROXY_EXT}"
export APP_INT=`cat ${ROOT_TEMP}/app_internal_ip.txt`
echo "APP_INT is ${APP_INT}"
export URL1="postgresql://${DBUSER}:${DBPW}@${HAPROXY_EXT}:26257/defaultdb?sslmode=require"
export URL="postgresql://${DBUSER}:${DBPW}@${HAPROXY_EXT}:26257/movr?sslmode=require"
echo ${URL1}
echo ${URL}
cockroach workload init movr $URL 
cockroach sql --url $URL --execute "SET CLUSTER SETTING enterprise.license = \"${COCKROACH_DEV_LICENSE}\";"
cockroach sql --url $URL --execute "SET CLUSTER SETTING cluster.organization = \"${COCKROACH_DEV_ORGANIZATION}\";"
cockroach sql --url $URL --execute "SET CLUSTER SETTING kv.rangefeed.enabled = true;"
cockroach sql --url $URL <<EOF
CREATE CHANGEFEED FOR TABLE movr.users,movr.vehicles,movr.rides,movr.vehicle_location_histories,movr.promo_codes,movr.user_promo_codes
  INTO "webhook-https://${APP_INT}:30004/movr/public?insecure_tls_skip_verify=true"
  WITH updated, resolved='1s', min_checkpoint_frequency='1s',
       webhook_sink_config='{"Flush":{"Messages":10000,"Frequency":"1s"}}';
EOF
