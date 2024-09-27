#!/bin/bash

###
# create cluster
###
docker-compose exec -T redis_1 <<EOF
  echo "yes" | redis-cli --cluster create   173.17.0.11:6379   173.17.0.12:6379   173.17.0.13:6379 --cluster-replicas 1
EOF