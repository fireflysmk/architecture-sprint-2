#!/bin/bash

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF
docker compose exec -T shard1-a mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1-a:27018" },
        { _id : 1, host : "shard1-b:27018" },
        { _id : 2, host : "shard1-c:27018" },
      ]
    }
);
EOF

docker compose exec -T shard2-a mongosh --port 27019 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2-a:27019" },
        { _id : 1, host : "shard2-b:27019" },
        { _id : 2, host : "shard2-c:27019" },
      ]
    }
  );
EOF

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard( "shard1/shard1-a:27018");
sh.addShard( "shard1/shard1-b:27018");
sh.addShard( "shard1/shard1-c:27018");
sh.addShard( "shard2/shard2-a:27019");
sh.addShard( "shard2/shard2-b:27019");
sh.addShard( "shard2/shard2-c:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb;
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

