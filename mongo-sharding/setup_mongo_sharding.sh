#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

docker-compose down -v

docker-compose up -d

echo -e "${GREEN}Ожидание инициализации MongoDB контейнеров...${NC}"
sleep 15

echo -e "${GREEN}Инициализация реплицированного набора config_server...${NC}"
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [{ _id: 0, host: "configSrv:27017" }]
})
EOF

echo -e "${GREEN}Инициализация реплицированного набора shard1...${NC}"
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1",
  members: [{ _id: 0, host: "shard1:27018" }]
})
EOF

echo -e "${GREEN}Инициализация реплицированного набора shard2...${NC}"
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "shard2",
  members: [{ _id: 0, host: "shard2:27019" }]
})
EOF

echo -e "${GREEN}Ожидание инициализации реплицированных наборов...${NC}"
sleep 10

echo -e "${GREEN}Добавление шардов в кластер...${NC}"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27018")
sh.addShard("shard2/shard2:27019")
EOF

sleep 5

echo -e "${GREEN}Настройка базы данных 'somedb' и шардирование коллекции 'helloDoc'...${NC}"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
sh.enableSharding("somedb")
db.createCollection("helloDoc")
db.helloDoc.createIndex({ _id: "hashed" })
sh.shardCollection("somedb.helloDoc", { _id: "hashed" })
EOF

echo -e "${GREEN}Вставка данных в коллекцию 'helloDoc'...${NC}"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for (var i = 0; i < 1000; i++) {
  db.helloDoc.insertOne({ age: i, name: "ly" + i })
}
EOF

echo -e "${GREEN}Настройка шардированного кластера и загрузка данных завершены.${NC}"
