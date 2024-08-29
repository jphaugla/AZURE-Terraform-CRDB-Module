export DASHBOARD_DIR=grafana_dashboards
mkdir $DASHBOARD_DIR
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/changefeeds.json'  > ${DASHBOARD_DIR}/changefeeds.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/crosscluster_replication.json'  > ${DASHBOARD_DIR}/crosscluster_replication.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/distributed.json'  > ${DASHBOARD_DIR}/distributed.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/hardware.json'  > ${DASHBOARD_DIR}/hardware.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/overview.json'  > ${DASHBOARD_DIR}/overview.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/queues.json'  > ${DASHBOARD_DIR}/queues.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/replication.json'  > ${DASHBOARD_DIR}/replication.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/runtime.json'  > ${DASHBOARD_DIR}/runtime.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/slow_request.json'  > ${DASHBOARD_DIR}/slow_request.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/sql.json'  > ${DASHBOARD_DIR}/sql.json
curl 'https://raw.githubusercontent.com/cockroachdb/cockroach/master/monitoring/grafana-dashboards/by-cluster/storage.json'  > ${DASHBOARD_DIR}/storage.json
# for replicator
curl 'https://raw.githubusercontent.com/cockroachdb/replicator/master/scripts/dashboard/replicator.json' > ${DASHBOARD_DIR}/replicator.json
