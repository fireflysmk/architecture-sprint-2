###
# Проверка
###

docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard1 mongosh --port 27023 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
print(rs.status().members.length)
EOF

docker compose exec -T shard2 mongosh --port 27026 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
print(rs.status().members.length)
EOF