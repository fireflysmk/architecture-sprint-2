#!/bin/bash

###
# show count repl
###
docker-compose exec -T mongos_router_1 mongosh --port 27020 <<EOF
  use somedb;

  db.adminCommand({ getShardMap: 1 });
EOF

docker-compose exec -T mongos_router_2 mongosh --port 27021 <<EOF
  use somedb;

  db.adminCommand({ getShardMap: 1 });
EOF