# thi needs to run on one of the Central CRDB nodes 
# the IP address is the Public IP one of the eastus2 crdb nodes.  For now, it can't be haproxy node
CREATE EXTERNAL CONNECTION 'pull_east_from_central' AS 'postgresql://jhaugland@20.96.183.150:26257?sslmode=verify-full&sslrootcert=/home/adminuser/eastus2_certs/ca.crt&sslcert=/home/adminuser/eastus2_certs/client.jhaugland.crt&sslkey=/home/adminuser/eastus2_certs/client.jhaugland.key';
