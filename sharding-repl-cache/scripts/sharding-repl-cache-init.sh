#!/bin/bash

echo -e "configSrv..."
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({_id : 'config_server',configsvr:true,members: [{ _id : 0, host : 'configSrv:27017' }]});
EOF
echo -e "Инициализация configSrv завершена."

#######################################################################

sleep 5
echo -e "\n\nShard1..."
docker compose exec -T shard1-primary mongosh --port 27018 --quiet <<EOF
rs.initiate({
    _id : "shard1ReplicaSet",
    members: [
        { _id : 0, host : "shard1-primary:27018" },
        { _id : 1, host : "shard1-secondary1:27019" },
        { _id : 2, host : "shard1-secondary2:27020" }
    ]
});
EOF
echo -e "Инициализация Shard1 завершена."

#######################################################################

sleep 5
echo -e "\n\nShard2..."
docker compose exec -T shard2-primary mongosh --port 27021 --quiet <<EOF
rs.initiate({
    _id : "shard2ReplicaSet",
    members: [
        { _id : 0, host : "shard2-primary:27021" },
        { _id : 1, host : "shard2-secondary1:27022" },
        { _id : 2, host : "shard2-secondary2:27023" }
    ]
});
EOF
echo -e "Инициализация Shard2 завершена."

#######################################################################

sleep 5
echo -e "\n\nДобавление шардов в кластер..."
docker compose exec -T mongos_router mongosh --port 27024 --quiet <<EOF
sh.addShard("shard1ReplicaSet/shard1-primary:27018,shard1-secondary1:27019,shard1-secondary2:27020");
sh.addShard("shard2ReplicaSet/shard2-primary:27021,shard2-secondary1:27022,shard2-secondary2:27023");
EOF
echo -e "Добавление шардов в кластер завершено."

#######################################################################

sleep 5
echo -e "\n\nЗагрузка данных..."
docker compose exec -T mongos_router mongosh --port 27024 --quiet <<EOF
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
echo -e "\n\nПроверяем данные в shard1-primary..."
docker compose exec -T shard1-primary mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

sleep 5
echo -e "\n\nПроверяем данные в shard1-secondary1..."
docker compose exec -T shard1-secondary1 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

sleep 5
echo -e "\n\nПроверяем данные в shard1-secondary2..."
docker compose exec -T shard1-secondary2 mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

#######################################################################

sleep 5
echo -e "\n\nПроверяем данные в shard2-primary..."
docker compose exec -T shard2-primary mongosh --port 27021 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

sleep 5
echo -e "\n\nПроверяем данные в shard2-secondary1..."
docker compose exec -T shard2-secondary1 mongosh --port 27022 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

sleep 5
echo -e "\n\nПроверяем данные в shard2-secondary2..."
docker compose exec -T shard2-secondary2 mongosh --port 27023 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
