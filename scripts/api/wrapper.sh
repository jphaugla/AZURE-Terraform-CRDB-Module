# need to change the session in here and then can run all hte other commands
command=$1
CRDB_IP=172.206.98.88
SESSION='CIGA/rTxzd2ADhIQNsouJQNIxfH5de+/Jj2qtg=='
PORT=8080
PREFIX='/api/v2/'
curl -k -H "X-Cockroach-API-Session: ${SESSION}" https://${CRDB_IP}:${PORT}${PREFIX}${command}/
