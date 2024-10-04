CRDB_IP=172.206.98.88
PORT=8080
PREFIX='/api/v2/'
# curl -k --request POST --url "https://${CRDB_IP}:8080${PREFIX}login/?username=jhaugland&password=jasonrocks" --header 'content-type: application/x-www-form-urlencoded'
curl -k --request POST --url "https://${CRDB_IP}:${PORT}${PREFIX}login/?username=jhaugland&password=jasonrocks" --header 'content-type: application/x-www-form-urlencoded'
