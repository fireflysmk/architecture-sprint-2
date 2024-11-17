#!/bin/bash

###
# Проверяем реплики
###

docker compose exec -T mongo_shard1_replica mongo --port 27020 <<EOF
rs.status()

rs.secondaryOk()
use somedb
db.helloDoc.find().count()
EOF

docker compose exec -T mongo_shard2_replica mongo --port 27024 <<EOF
rs.status()

rs.secondaryOk()
use somedb
db.helloDoc.find().count()
EOF
