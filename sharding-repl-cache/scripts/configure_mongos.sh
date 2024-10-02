docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27023");
sh.addShard("shard2/shard2:27026");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF