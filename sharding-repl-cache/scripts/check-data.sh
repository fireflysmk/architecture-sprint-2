#!/bin/bash

new_line=$'\n'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

echo -e "${BLUE}All documents:${NO_COLOR}"
sleep 1
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
sleep 1
echo -e "${new_line}${BLUE}Shard-1 documents:${NO_COLOR}"
sleep 1
docker compose exec -T shard-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
sleep 1
echo -e "${new_line}${BLUE}Shard-2 documents:${NO_COLOR}"
sleep 1
docker compose exec -T shard-2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
sleep 1
echo -e "${new_line}${BLUE}Shard-1 replics:${NO_COLOR}"
sleep 1
docker compose exec -T shard-1 mongosh --port 27018 --quiet <<EOF
rs.status();
exit();
EOF
sleep 1
echo -e "${new_line}${BLUE}Shard-2 replics:${NO_COLOR}"
sleep 1
docker compose exec -T shard-2 mongosh --port 27019 --quiet <<EOF
rs.status();
exit();
EOF
sleep 1
echo -e "${new_line}${BLUE}Redis nodes:${NO_COLOR}"
sleep 1
docker compose exec -T redis_1 redis-cli cluster nodes
sleep 1
echo -e "${new_line}${GREEN}ALL checks DONE${NO_COLOR}"
sleep 1
