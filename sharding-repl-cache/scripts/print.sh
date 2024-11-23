#!/bin/bash

docker compose exec -T shard1_db1 mongosh --port 27018 --quiet <<EOF
\`shard count=\${rs.status().members.length}\`
EOF

docker compose exec -T shard2_db1 mongosh --port 27019 --quiet <<EOF
\`shard count=\${rs.status().members.length}\`
EOF