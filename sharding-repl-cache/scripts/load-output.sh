#!/bin/bash

###
# печать результатов
###

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
\`NOTE: helloDoc count=\${db.helloDoc.countDocuments()}\`
EOF


docker compose exec -T shard1_db1 mongosh --port 27018 --quiet <<EOF
\`OUTPUT: shard1 repl count=\${rs.status().members.length}\`
EOF

docker compose exec -T shard1_db1 mongosh --port 27018 --quiet <<EOF
use somedb;
\`NOTE: shard1_db1 doc count=\${db.helloDoc.countDocuments()}\`
EOF

docker compose exec -T shard1_db2 mongosh --port 27028 --quiet <<EOF
use somedb;
\`NOTE: shard1_db2 doc count=\${db.helloDoc.countDocuments()}\`
EOF

docker compose exec -T shard1_db3 mongosh --port 27038 --quiet <<EOF
use somedb;
\`NOTE: shard1_db3 doc count=\${db.helloDoc.countDocuments()}\`
EOF


docker compose exec -T shard2_db1 mongosh --port 27019 --quiet <<EOF

\`OUTPUT: shard2 repl count=\${rs.status().members.length}\`
EOF

docker compose exec -T shard2_db1 mongosh --port 27019 --quiet <<EOF
use somedb;
\`NOTE: shard2_db1 doc count=\${db.helloDoc.countDocuments()}\`
EOF

docker compose exec -T shard2_db2 mongosh --port 27029 --quiet <<EOF
use somedb;
\`NOTE: shard2_db2 doc count=\${db.helloDoc.countDocuments()}\`
EOF

docker compose exec -T shard2_db3 mongosh --port 27039 --quiet <<EOF
use somedb;
\`NOTE: shard2_db3 doc count=\${db.helloDoc.countDocuments()}\`
EOF