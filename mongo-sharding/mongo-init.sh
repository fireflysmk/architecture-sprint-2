#!/bin/bash

docker-compose up -d

echo "Start configuration"
docker-compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id: "config-server-rs",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" },
    ]
  }
);
EOF
sleep 10

docker compose exec -T shard1 mongosh --port 27017 <<EOF
rs.initiate( { _id : "shard1-rs", members: [{ _id : 0, host : "shard1:27017" }, ] } );
EOF

docker compose exec -T shard2 mongosh --port 27017 <<EOF
rs.initiate( { _id : "shard2-rs", members: [{ _id : 0, host : "shard2:27017" }, ] } );
EOF

docker-compose exec -T router mongosh --port 27017 <<EOF
sh.addShard( "shard1-rs/shard1:27017");
sh.addShard( "shard2-rs/shard2:27017");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );
EOF

echo "Create data"
docker-compose exec -T router mongosh <<EOF
use somedb;
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

echo "Count via router"
docker compose exec -T router mongosh --port 27017 <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo "Count via shard1"
docker compose exec -T shard1 mongosh --port 27017 <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo "Count via shard2"
docker compose exec -T shard2 mongosh --port 27017 <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF