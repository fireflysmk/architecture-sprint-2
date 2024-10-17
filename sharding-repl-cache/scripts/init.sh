#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config-server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

sleep 1

docker compose exec -T shard1_1 mongosh --port 27010 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1_1:27010" },
        { _id : 1, host : "shard1_2:27011" },
        { _id : 2, host : "shard1_3:27012" },
      ]
    }
);
EOF

sleep 1

docker compose exec -T shard2_1 mongosh --port 27013 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2_1:27013" },
        { _id : 1, host : "shard2_2:27014" },
        { _id : 2, host : "shard2_3:27015" }
      ]
    }
);
EOF

sleep 1

docker compose exec -T redis redis-cli