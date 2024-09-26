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
            _id : "replSet1",
            members: [
                {_id: 0, host: "shard1:27018"},
                {_id: 1, host: "shard1_1:27022"},
                {_id: 2, host: "shard1_2:27023"}
            ]
        }
    );
EOF

docker-compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
    rs.initiate(
        {
            _id : "replSet2",
            members: [
                {_id: 0, host: "shard2:27019"},
                {_id: 1, host: "shard2_1:27024"},
                {_id: 2, host: "shard2_2:27025"}
            ]
        }
    );
EOF


###
# add shards, init bd
###
docker-compose exec -T mongos_router_1 mongosh --port 27020 --quiet <<EOF
    sh.addShard("replSet1/shard1:27018,shard1_1:27022,shard1_2:27023");
    sh.addShard("replSet2/shard2:27019,shard2_1:27024,shard2_2:27025");

    sh.enableSharding("somedb");
    sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

    use somedb;

    for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i});
EOF

docker-compose exec -T mongos_router_2 mongosh --port 27021 --quiet <<EOF
    db.adminCommand({ getShardMap: 1 });
EOF