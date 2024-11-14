#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T mongodb1 mongo <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

