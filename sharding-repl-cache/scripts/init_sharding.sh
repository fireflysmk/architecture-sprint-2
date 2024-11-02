	docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate({_id : 'config_server',configsvr: true,members: [{ _id : 0, host : 'configSrv:27017' }]});
EOF

docker compose exec -T masterA mongosh --port 27018 <<EOF
rs.initiate({
  _id: "masterA",
  members: [
    { _id: 0, host: "masterA:27018" },
    { _id: 1, host: "replicaA1:27018" },
    { _id: 2, host: "replicaA2:27018" },
    { _id: 3, host: "replicaA3:27018" }
  ]
});
EOF

docker compose exec -T masterB mongosh --port 27019 <<EOF
rs.initiate({
  _id: "masterB",
  members: [
    { _id: 0, host: "masterB:27019" },
    { _id: 1, host: "replicaB1:27019" },
    { _id: 2, host: "replicaB2:27019" },
    { _id: 3, host: "replicaB3:27019" }
  ]
});
EOF

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard( "masterA/masterA:27018");
sh.addShard( "masterB/masterB:27019");
sh.enableSharding("somedb");

db.helloDoc.createIndex({ "name": "hashed" });

sh.shardCollection("somedb.helloDoc", { "name" : "hashed" });
use somedb;
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i});
db.helloDoc.countDocuments();
EOF

docker exec -it redis_1 redis-cli --cluster create \
  173.23.0.2:6379 \
  173.23.0.3:6379 \
  173.23.0.4:6379 \
  173.23.0.5:6379 \
  173.23.0.6:6379 \
  173.23.0.17:6379 \
  --cluster-replicas 1