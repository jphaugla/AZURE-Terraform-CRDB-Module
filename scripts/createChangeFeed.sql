create changefeed for table defaultdb.account, defaultdb.customer, defaultdb.dispute,defaultdb.email,defaultdb.merchant,defaultdb.phone,defaultdb.transaction,defaultdb.transaction_return into 'webhook-https://52.232.178.198:30004/defaultdb/public?insecure_tls_skip_verify=true' with diff, updated, resolved='5s';
