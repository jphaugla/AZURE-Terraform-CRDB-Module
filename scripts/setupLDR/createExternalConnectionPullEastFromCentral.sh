# must run on an east crdb node 
cockroach sql --host=localhost --certs-dir=certs --user=jhaugland --file createExternalConnectionPullEastFromCentral.sql
