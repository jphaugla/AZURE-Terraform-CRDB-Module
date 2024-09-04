export GRAFANA_HOST=104.209.214.206
export GRAFANA_PORT=3000
export DASHBOARD_DIR=grafana_dashboards
export DBPW=jasonrocks
# curl -X POST --insecure -H "Authorization: Bearer $apikey" -H "Content-Type: application/json" -d @hi.json http://192.168.8.14:3000/api/dashboards/import
# curl -X GET -H "Content-Type: application/json" "http://${GRAFAN_HOST}:${GRAFANA_PORT}/api/serviceaccounts/search?perpage=10&page=1&query=mygraf HTTP/1.1"
# Accept: application/json
# Content-Type: application/json
# Authorization: Basic YWRtaW46YWRtaW4=
#  simple test I found that actually works
# curl --request POST 'http://104.209.214.206:3000/api/admin/users' --user "admin:${DBPW}" --header 'Content-Type: application/json' --data-raw '{"name":"test","email":"test","login":"test","password":"test"}'
# import a dashboard
# curl -v --request POST 'http://104.209.214.206:3000/api/dashboards/db' --user "admin:${DBPW}" --header 'Content-Type: application/json' -d "@${DASHBOARD_DIR}/changefeeds.json"
curl -v --request POST 'http://104.209.214.206:3000/api/dashboards/db' --user "admin:${DBPW}" --header 'Content-Type: application/json' -d "@${DASHBOARD_DIR}/hardware.json"
