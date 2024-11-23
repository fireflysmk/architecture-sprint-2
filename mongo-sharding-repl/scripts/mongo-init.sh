#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

docker compose exec -T shard1_db1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        {_id : 0, host : "shard1_db1:27018" },
        {_id : 1, host: "shard1_db2:27028"},
        {_id : 2, host: "shard1_db3:27038"}
      ]
    }
);
EOF

docker compose exec -T shard2_db1 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        {_id : 0, host : "shard2_db1:27019" },
        {_id : 1, host: "shard2_db2:27029"},
        {_id : 2, host: "shard2_db3:27039"}
      ]
    }
  );
EOF

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard( "shard1/shard1_db1:27018");
sh.addShard( "shard2/shard2_db1:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
