docker exec -it mongos_router mongosh --port 27025 <<EOF
use somedb;
db.helloDoc.countDocuments(); 
EOF
 
docker exec -it shard1 mongosh --port 27023 <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
 
docker exec -it shard2 mongosh --port 27024 <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF