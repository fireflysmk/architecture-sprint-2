#!/bin/bash

###
# Добавляем шарды в роутер
###

docker compose exec -T mongo_router mongo --port 27017 <<EOF
sh.addShard("shard1/mongo_shard1:27019");
sh.addShard("shard2/mongo_shard2:27020");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF
