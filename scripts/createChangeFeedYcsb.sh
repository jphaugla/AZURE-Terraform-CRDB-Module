# this is haproxy node on source side
#  since running from my mac, using public ip
export SRC_HAPROXY=20.14.141.158
# this is internal ip for  application node on source side
export APP_INT=192.168.3.101
export DBUSER=jhaugland
export DBPW=jasonrocks
export URL_REQUIRE="postgresql://{DBUSER}:{DBPW}@${SRC_HAPROXY}:26257/ycsb?sslmode=require"
cockroach sql --url $URL_REQUIRE --execute "SET CLUSTER SETTING enterprise.license = \"${COCKROACH_DEV_LICENSE}\";"
cockroach sql --url $URL_REQUIRE --execute "SET CLUSTER SETTING cluster.organization = \"${COCKROACH_DEV_ORGANIZATION}\";"
cockroach sql --url $URL_REQUIRE --execute "SET CLUSTER SETTING kv.rangefeed.enabled = true;"
cockroach sql --url $URL_REQUIRE <<EOF
CREATE CHANGEFEED FOR TABLE YCSB.USERTABLE
  INTO "webhook-https://${APP_INT}:30004/ycsb/public?insecure_tls_skip_verify=true"
  WITH updated, resolved='1s', min_checkpoint_frequency='1s',
       webhook_sink_config='{"Flush":{"Messages":10000,"Frequency":"1s"}}';
EOF
