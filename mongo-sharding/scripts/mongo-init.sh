#!/bin/bash

###
# init config
###
docker-compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
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

###
# init shards
###
docker-compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
    rs.initiate(
        {
            _id : "shard1",
            members: [
                { _id : 0, host : "shard1:27018" }
            ]
        }
    );
EOF

docker-compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
    rs.initiate(
        {
            _id : "shard2",
            members: [
                { _id : 0, host : "shard2:27019" }
            ]
        }
    );
EOF


###
# add shard, init bd
###
docker-compose exec -T mongos_router_1 mongosh --port 27020 --quiet <<EOF
    sh.addShard("shard1/shard1:27018");
    sh.addShard("shard2/shard2:27019");

    sh.enableSharding("somedb");
    sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

    use somedb;

    for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i});
EOF

docker-compose exec -T mongos_router_2 mongosh --port 27021 --quiet <<EOF
    db.adminCommand({ getShardMap: 1 });
EOF