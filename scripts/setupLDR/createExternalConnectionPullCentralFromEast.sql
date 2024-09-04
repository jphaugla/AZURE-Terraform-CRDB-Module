# this needs to run on one of the East CRDB nodes 
# the IP address is the Private IP one of the centralus crdb nodes.  For now, it can't be haproxy node
# must delete these comment lines for it to run in SQL
# must change the user to your user id
CREATE EXTERNAL CONNECTION 'pull_central_from_east' AS 'postgresql://jhaugland@20.84.145.187:26257/kv?sslmode=verify-full&sslrootcert=/home/adminuser/centralus_certs/ca.crt&sslcert=/home/adminuser/centralus_certs/client.jhaugland.crt&sslkey=/home/adminuser/centralus_certs/client.jhaugland.key';
