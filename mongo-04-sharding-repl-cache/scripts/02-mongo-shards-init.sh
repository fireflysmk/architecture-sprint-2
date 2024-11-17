#!/bin/bash

###
# Инициализируем шарды с репликами
###

# shard1

docker compose exec -T mongo_shard1 mongo --port 27019 <<EOF
rs.initiate({
    _id : "shard1",
    members: [
      { _id: 0, host: "mongo_shard1:27019" },
      { _id: 1, host: "mongo_shard1_replica:27020" }
    ]
});
EOF

# shard2

docker compose exec -T mongo_shard2 mongo --port 27023 <<EOF
rs.initiate({
    _id : "shard2",
    members: [
      { _id: 0, host: "mongo_shard2:27023" },
      { _id: 1, host: "mongo_shard2_replica:27024" }
    ]
});
EOF
