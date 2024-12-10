# this is Haproxy on the target region so it must be public
export TGT_HAPROXY=52.184.153.153
export PASSWORD=jasonrocks
export DBUSER=jhaugland
export URL_REQUIRE="postgresql://${DBUSER}:${PASSWORD}@${TGT_HAPROXY}:26257/movr?sslmode=require"
export URL="postgresql://${DBUSER}@${TGT_HAPROXY}:26257/?sslmode=require&sslrootcert=target-certs/ca.crt&sslcert=target-certs/client.${DBUSER}.crt&sslkey=target-certs/client.${DBUSER}.key"
cockroach sql --url=${URL}
	

"""with account_rows as (
                insert into accounts ( account_id, name )
Value
                insert into orders ( account_id, name )
                select (select account_id from account_rows) as account_id, 'order 1'
                insert into positions ( account_id, name )
                select (select account_id from account_rows) as account_id, 'position 1'
                insert into balances ( account_id, amount )
                select (select account_id from account_rows) as account_id, 1.0
                select (select account_id from account_rows) as account_id, 1.0
                select (select account_id from account_rows) as account_id, 1.0
                select (select account_id from account_rows) as account_id, 1.0
                select (select account_id from account_rows) as account_id, 1.0
                insert into order_legs ( order_id, name )
                select (select order_id from order_rows) as order_id, 'order leg 1'
                select (select order_id from order_rows) as order_id, 'order leg 2' 
                select (select order_id from order_rows) as order_id, 'order leg 3' 
                select (select order_id from order_rows) as order_id, 'order leg 4' 
                """