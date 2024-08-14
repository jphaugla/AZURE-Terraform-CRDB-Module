# this needs to run on one of the Central CRDB nodes 
# the IP address is the Public IP of the eastus2 haproxy node 
CREATE EXTERNAL CONNECTION 'PULL_EAST_FROM_CENTRAL' AS 'postgresql://jhaugland@172.203.68.111:26257?sslmode=verify-full&sslrootcert=/home/adminuser/eastus2_certs/ca.crt&sslcert=/home/adminuser/eastus2_certs/client.jhaugland.crt&sslkey=/home/adminuser/eastus2_certs/client.jhaugland.key';
