export CONNECT='postgresql://jhaugland:jasonrocks@172.206.98.88:26257/defaultdb?sslmode=require'
cockroach sql --url=${CONNECT}
