#!/bin/bash

###
# Тест бд
###

docker compose exec -T shard1_1 mongosh --port 27010 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

docker compose exec -T shard1_2 mongosh --port 27011 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

docker compose exec -T shard1_3 mongosh --port 27012 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF


docker compose exec -T shard2_1 mongosh --port 27013 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

docker compose exec -T shard2_2 mongosh --port 27014 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

docker compose exec -T shard2_3 mongosh --port 27015 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF