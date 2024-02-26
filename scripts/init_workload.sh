export URL="postgresql://root@localhost:26257/?sslmode=verify-full&sslrootcert=certs/ca.crt&sslcert=certs/client.root.crt&sslkey=certs/client.root.key"
cockroach workload init movr $URL
cockroach workload --duration '5s' run movr $URL
cockroach sql --url=$URL -e "TRUNCATE TABLE MOVR.RIDES CASCADE; TRUNCATE TABLE MOVR.USERS CASCADE; TRUNCATE MOVR.VEHICLES CASCADE; TRUNCATE MOVR.VEHICLE_LOCATION_HISTORIES CASCADE; TRUNCATE TABLE MOVR.PROMO_CODES; TRUNCATE TABLE MOVR.USER_PROMO_CODES;"
