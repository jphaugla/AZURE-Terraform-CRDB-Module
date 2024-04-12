# must change the host IP addressto the app node external address on the destination region
cockroach sql --host=localhost --certs-dir=certs --file create-changefeed-kv.sql
