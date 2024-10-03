#!/bin/bash
set -x

###
# Инициализируем кластер Redis
###

docker compose exec redis_1 redis-cli --cluster create 173.17.0.11:6379 173.17.0.12:6379 173.17.0.13:6379 173.17.0.14:6379 173.17.0.15:6379 173.17.0.16:6379 --cluster-replicas 1 --cluster-yes
