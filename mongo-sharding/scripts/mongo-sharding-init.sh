#!/bin/bash

echo -e "configSrv..."
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({_id : 'config_server',configsvr:true,members: [{ _id : 0, host : 'configSrv:27017' }]});
EOF
echo -e "Инициализация configSrv завершена."

#######################################################################

sleep 5
echo -e "\n\nShard1..."
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({_id : "shard1",members: [{ _id : 0, host : "shard1:27018" }]});
EOF
echo -e "Инициализация Shard1 завершена."

#######################################################################

sleep 5
echo -e "\n\nShard2..."
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({_id : "shard2",members: [{ _id : 0, host : "shard2:27019" }]});
EOF
echo -e "Инициализация Shard2 завершена."

#######################################################################

sleep 5
echo -e "\n\nДобавление шардов в кластер..."
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27018");
sh.addShard("shard2/shard2:27019");
EOF
echo -e "Добавление шардов в кластер завершено."

#######################################################################

sleep 5
echo -e "\n\nЗагрузка данных..."
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
sh.enableSharding("somedb");
db.createCollection("helloDoc")
db.helloDoc.createIndex({ "name": "hashed" });
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" });

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});
db.helloDoc.countDocuments();
EOF
echo -e "Загрузка данных завершена."

#######################################################################

sleep 5
echo -e "\n\nПроверяем данные в Shard1..."
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

#######################################################################

sleep 5
echo -e "\n\nПроверяем данные в Shard2..."
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
