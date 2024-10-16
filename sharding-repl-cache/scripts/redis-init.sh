#!/bin/bash

docker-compose exec -T redis_1 sh --quiet <<EOF
echo "yes" | redis-cli --cluster create   173.17.0.26:6379   173.17.0.27:6379   173.17.0.28:6379   173.17.0.29:6379   173.17.0.30:6379   173.17.0.31:6379   --cluster-replicas 1
EOF