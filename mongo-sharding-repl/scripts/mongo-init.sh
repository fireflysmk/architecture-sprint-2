#!/bin/bash

new_line=$'\n'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

###
# Инициализируем MongoDB с шардами
###

echo -e "${new_line}${BLUE}Initialize MongoDB start${NO_COLOR}"
sleep 1
echo -e "${new_line}${BLUE}Initialize Server of configuration start${NO_COLOR}"
sleep 1
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF

rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
); 
exit();
EOF
sleep 1
echo -e "${new_line}${GREEN}Initialize Server of configuration finished${NO_COLOR}"
echo -e "${new_line}${BLUE}Initialize MongoDB Shard-1 start${NO_COLOR}"
sleep 1
docker compose exec -T shard-1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard-1",
      members: [
        { _id : 0, host : "shard-1:27018" },
        { _id : 1, host : "shard-1-1:27021" },
        { _id : 2, host : "shard-1-2:27022" }
      ]
    }
); 
exit();
EOF
sleep 1
echo -e "${new_line}${GREEN}Initialize MongoDB Shard-1 finished${NO_COLOR}"
echo -e "${new_line}${BLUE}Initialize MongoDB Shard-2 start${NO_COLOR}"
sleep 1
docker compose exec -T shard-2 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard-2",
      members: [
        { _id : 3, host : "shard-2:27019" },
        { _id : 4, host : "shard-2-1:27023" },
        { _id : 5, host : "shard-2-2:27024" },
      ]
    }
  ); 
exit(); 
EOF
sleep 1
echo -e "${new_line}${GREEN}Initialize MongoDB Shard-2 finished${NO_COLOR}"
echo -e "${new_line}${BLUE}Initialize MongoDB Router start${NO_COLOR}"
sleep 1
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard-1/shard-1:27018");
sh.addShard( "shard-1/shard-1-1:27021");
sh.addShard( "shard-1/shard-1-2:27022");
sh.addShard( "shard-2/shard-2:27019");
sh.addShard( "shard-2/shard-2-1:27023");
sh.addShard( "shard-2/shard-2-2:27024");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i}); 
exit();
EOF
sleep 1
echo -e "${new_line}${BLUE}Initialize MongoDB Router finished${NO_COLOR}"
echo -e "${new_line}${GREEN}Initialize ALL MongoDB finished${NO_COLOR}"
