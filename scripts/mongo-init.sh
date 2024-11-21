#!/bin/bash

# Подождем, пока MongoDB контейнеры будут готовы
echo "Ждем, пока MongoDB контейнеры будут готовы..."
sleep 30

# Инициализируем репликационные наборы для шардов
echo "Инициализация репликационного набора для shard1..."
mongosh --host shard1:27018 --eval 'rs.initiate({
  _id: "shard1",
  members: [
    { _id: 0, host: "shard1:27018" },
    { _id: 1, host: "shard1_replica1:27021" },
    { _id: 2, host: "shard1_replica2:27022" }
  ]
})'

echo "Инициализация репликационного набора для shard2..."
mongosh --host shard2:27019 --eval 'rs.initiate({
  _id: "shard2",
  members: [
    { _id: 0, host: "shard2:27019" },
    { _id: 1, host: "shard2_replica1:27023" },
    { _id: 2, host: "shard2_replica2:27024" }
  ]
})'

# Инициализируем репликационный набор для конфигурационного сервера
echo "Инициализация репликационного набора для конфигурационного сервера..."
mongosh --host configSrv:27017 --eval 'rs.initiate({
  _id: "config_server",
  members: [
    { _id: 0, host: "configSrv:27017" }
  ]
})'

echo "Ожидание настройки шардирования..."
sleep 10
# Настроим шардинг
echo "Настройка шардирования..."
mongosh --host mongos_router:27020 --eval 'sh.addShard("shard1/shard1:27018,shard1_replica1:27021,shard1_replica2:27022")'
mongosh --host mongos_router:27020 --eval 'sh.addShard("shard2/shard2:27019,shard2_replica1:27023,shard2_replica2:27024")'

# Подключим конфигурационный сервер
echo "Подключение конфигурационного сервера к кластеру..."
mongosh --host mongos_router:27020 --eval 'sh.addShardTag("shard1", "shard1")'
mongosh --host mongos_router:27020 --eval 'sh.addShardTag("shard2", "shard2")'

# Запуск кластеризации
echo "Запуск шардирования для базы данных somedb..."
mongosh --host mongos_router:27020 --eval 'sh.enableSharding("somedb")'

echo "Создаем коллекцию helloDoc в базе somedb и настраиваем шардинг..."
mongosh --host mongos_router:27020 --eval '
db.getSiblingDB("somedb").createCollection("helloDoc");
db.getSiblingDB("somedb").helloDoc.createIndex({ "_id": "hashed" });
sh.shardCollection("somedb.helloDoc", { "_id": "hashed" });
'
echo "Инициализация и настройка MongoDB завершены!"