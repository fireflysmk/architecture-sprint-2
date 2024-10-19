#!/bin/bash

new_line=$'\n'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

###
# Инициализируем Redis в кластерном режиме
###

echo -e "${new_line}${BLUE}Initialize Redis Cluster start${NO_COLOR}"
sleep 1
docker compose exec redis_1 redis-cli --cluster create 173.18.0.15:6379 173.18.0.16:6379 173.18.0.17:6379 173.18.0.18:6379 173.18.0.19:6379 173.18.0.20:6379 --cluster-replicas 1 --cluster-yes
sleep 1
echo -e "${new_line}${GREEN}Initialize Redis Cluster finished${NO_COLOR}"
