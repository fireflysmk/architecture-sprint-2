#!/bin/bash

###
# Заполнение бд
###

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1_1:27010");
sh.addShard("shard1/shard1_2:27011");
sh.addShard("shard1/shard1_3:27012");
sh.addShard("shard2/shard2_1:27013");
sh.addShard("shard2/shard2_2:27014");
sh.addShard("shard2/shard2_3:27015");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb;

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})

db.helloDoc.countDocuments();
EOF
