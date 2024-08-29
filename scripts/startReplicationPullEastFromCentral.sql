use kv;
CREATE LOGICAL REPLICATION STREAM FROM TABLE KV.KV ON 'external://pull_east_from_central' INTO TABLE KV.KV;
