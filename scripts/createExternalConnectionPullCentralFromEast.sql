# thi needs to run on one of the Central CRDB nodes 
# the IP address is the Public IP one of the centralus crdb nodes.  For now, it can't be haproxy node
CREATE EXTERNAL CONNECTION 'pull_central_from_east' AS 'postgresql://jhaugland@20.84.145.187:26257?sslmode=verify-full&sslrootcert=/home/adminuser/centralus_certs/ca.crt&sslcert=/home/adminuser/centralus_certs/client.jhaugland.crt&sslkey=/home/adminuser/centralus_certs/client.jhaugland.key';
