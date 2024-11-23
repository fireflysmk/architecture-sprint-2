#!/bin/bash

###
# Очистка бд
###

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
db.dropDatabase();
\`WARNING!!! \${db.getName()} is dropped\`
EOF
