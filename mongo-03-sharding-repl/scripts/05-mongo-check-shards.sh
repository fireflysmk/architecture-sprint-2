#!/bin/bash

###
# Проверяем шарды
###

docker compose exec -T mongo_shard1 mongo --port 27019 <<EOF
use somedb
db.helloDoc.find().count()
EOF

docker compose exec -T mongo_shard2 mongo --port 27023 <<EOF
use somedb
db.helloDoc.find().count()
EOF
