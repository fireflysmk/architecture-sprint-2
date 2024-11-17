#!/bin/bash

###
# Инициализируем сервер конфигурации
###

docker compose exec -T mongo_config_srv mongo --port 27018 <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [{ _id: 0, host: "mongo_config_srv:27018" }]
});
EOF
