use kv;
CREATE LOGICAL REPLICATION STREAM FROM TABLE KV.KV ON 'postgresql://jhaugland@20.84.145.187:26257/kv?sslmode=verify-full&sslrootcert=/home/adminuser/centralus_certs/ca.crt&sslcert=/home/adminuser/centralus_certs/client.jhaugland.crt&sslkey=/home/adminuser/centralus_certs/client.jhaugland.key' INTO TABLE KV.KV;
