#!/bin/bash

###
# Конфигурация кластера
###

docker compose exec -T configSrv1 mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
      configsvr: true,
    members: [
      { _id : 0, host : "configSrv1:27017" },
    ]
  }
);
EOF

docker compose exec -T shard1 mongosh --port 27023 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27023" }
      ]
    }
);
EOF

docker compose exec -T shard2 mongosh --port 27026 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2:27026" },
      ]
    }
);
EOF

docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27023");
sh.addShard("shard2/shard2:27026");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

###
# Инициализация бд
###

docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF