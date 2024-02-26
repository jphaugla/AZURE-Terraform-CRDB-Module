# this is Haproxy on the target region so it must be public
export TGT_HAPROXY=40.83.35.248
export PASSWORD=jasonrocks
export URL_REQUIRE="postgresql://jhaugland:jasonrocks@${TGT_HAPROXY}:26257/movr?sslmode=require"
export URL="postgresql://jhaugland@${TGT_HAPROXY}:26257/?sslmode=require&ssljhauglandcert=target-certs/ca.crt&sslcert=target-certs/client.jhaugland.crt&sslkey=target-certs/client.jhaugland.key"
cockroach-sql sql --url=${URL_REQUIRE}
