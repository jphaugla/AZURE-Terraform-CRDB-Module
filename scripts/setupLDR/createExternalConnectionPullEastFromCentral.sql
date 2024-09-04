# thi needs to run on one of the Central CRDB nodes 
# the IP address is the Private  IP one of the eastus2 crdb nodes.  For now, it can't be haproxy node
# these 3 comment lines need to be removed
# must change the user from jhaugland to your user
CREATE EXTERNAL CONNECTION 'pull_east_from_central' AS 'postgresql://jhaugland@192.168.3.102:26257/kv?sslmode=verify-full&sslrootcert=/home/adminuser/eastus2_certs/ca.crt&sslcert=/home/adminuser/eastus2_certs/client.jhaugland.crt&sslkey=/home/adminuser/eastus2_certs/client.jhaugland.key';
