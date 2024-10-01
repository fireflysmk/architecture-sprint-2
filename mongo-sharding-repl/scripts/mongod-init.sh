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
      { _id : 1, host : "configSrv2:27018" },
      { _id : 2, host : "configSrv3:27019" }
    ]
  }
);
EOF

docker compose exec -T shard1 mongosh --port 27023 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27023" },
        { _id : 1, host : "shard1-2:27024" },
        { _id : 2, host : "shard1-3:27025" }
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
        { _id : 1, host : "shard2-2:27027" },
        { _id : 2, host : "shard2-3:27028" }
      ]
    }
);
EOF