	docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate({_id : 'config_server',configsvr: true,members: [{ _id : 0, host : 'configSrv:27017' }]});
EOF

docker compose exec -T masterA mongosh --port 27018 <<EOF
rs.initiate({_id : "masterA",members: [{ _id : 0, host : "masterA:27018" }]});
EOF

docker compose exec -T masterB mongosh --port 27019 <<EOF
rs.initiate({_id : "masterB",members: [{ _id : 1, host : "masterB:27019" }]});
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
