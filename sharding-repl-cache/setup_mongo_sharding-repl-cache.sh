#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

PROJECT_NAME="mongo-sharding-repl"

docker-compose -p $PROJECT_NAME down -v

docker-compose -p $PROJECT_NAME up -d

echo -e "${GREEN}Ожидание инициализации MongoDB контейнеров...${NC}"
sleep 20

echo -e "${GREEN}Инициализация реплицированного набора configReplSet...${NC}"
docker compose -p $PROJECT_NAME exec -T config1 mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [
    { _id: 0, host: "config1:27017" },
    { _id: 1, host: "config2:27017" },
    { _id: 2, host: "config3:27017" }
  ]
})
EOF

sleep 10

echo -e "${GREEN}Инициализация реплицированного набора shard1ReplSet...${NC}"
docker compose -p $PROJECT_NAME exec -T shard1a mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1ReplSet",
  members: [
    { _id: 0, host: "shard1a:27018" },
    { _id: 1, host: "shard1b:27018" },
    { _id: 2, host: "shard1c:27018" }
  ]
})
EOF

sleep 10

echo -e "${GREEN}Инициализация реплицированного набора shard2ReplSet...${NC}"
docker compose -p $PROJECT_NAME exec -T shard2a mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "shard2ReplSet",
  members: [
    { _id: 0, host: "shard2a:27019" },
    { _id: 1, host: "shard2b:27019" },
    { _id: 2, host: "shard2c:27019" }
  ]
})
EOF

sleep 10

echo -e "${GREEN}Добавление шардов в кластер...${NC}"
docker compose -p $PROJECT_NAME exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1ReplSet/shard1a:27018,shard1b:27018,shard1c:27018")
sh.addShard("shard2ReplSet/shard2a:27019,shard2b:27019,shard2c:27019")
EOF

sleep 5

echo -e "${GREEN}Настройка базы данных 'somedb' и шардирование коллекции 'helloDoc'...${NC}"
docker compose -p $PROJECT_NAME exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
sh.enableSharding("somedb")
db.createCollection("helloDoc")
db.helloDoc.createIndex({ _id: "hashed" })
sh.shardCollection("somedb.helloDoc", { _id: "hashed" })
EOF

echo -e "${GREEN}Вставка данных в коллекцию 'helloDoc'...${NC}"
docker compose -p $PROJECT_NAME exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for (var i = 0; i < 1000; i++) {
  db.helloDoc.insertOne({ age: i, name: "ly" + i })
}
EOF

echo -e "${GREEN}Настройка шардированного кластера с репликацией и загрузка данных завершены.${NC}"
