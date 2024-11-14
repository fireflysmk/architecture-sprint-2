#!/bin/bash

###
# Инициализируем шарды
###

docker compose exec -T mongo_shard1 mongo --port 27019 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "mongo_shard1:27019" },
      ]
    }
);
EOF

docker compose exec -T mongo_shard2 mongo --port 27020 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "mongo_shard2:27020" },
      ]
    }
);
EOF
