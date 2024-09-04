# must run on an east crdb node
DBUSER=jhaugland
cockroach sql --host=localhost --certs-dir=certs --user=${DBUSER} --file createExternalConnectionPullCentralFromEast.sql
