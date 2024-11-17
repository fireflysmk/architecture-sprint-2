#!/bin/bash

###
# Добавляем шарды и их реплики в роутер
###

docker compose exec -T mongo_router mongo --port 27017 <<EOF
sh.addShard("shard1/mongo_shard1:27019,mongo_shard1_replica:27020")
sh.addShard("shard2/mongo_shard2:27023,mongo_shard2_replica:27024")

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

sh.status()
EOF
