#!/bin/bash

###
# show doc count via router 1
###
docker-compose exec -T mongos_router_1 mongosh --port 27020 <<EOF
  use somedb;

  db.helloDoc.countDocuments();
EOF


###
# show doc count via router 2
###
docker-compose exec -T mongos_router_2 mongosh --port 27021 <<EOF
  use somedb

  db.helloDoc.countDocuments();
EOF

###
# show doc count shard 1
###
docker-compose exec -T shard1 mongosh --port 27018 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF

###
# show doc count shard 1 replica 1
###
docker-compose exec -T shard1_1 mongosh --port 27022 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF

###
# show doc count shard 1 replica 2
###
docker-compose exec -T shard1_2 mongosh --port 27023 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF

###
# show doc count shard 2
###
docker-compose exec -T shard2 mongosh --port 27019 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF

###
# show doc count shard 2 replica 1
###
docker-compose exec -T shard2_1 mongosh --port 27024 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF

###
# show doc count shard 2 replica 2
###
docker-compose exec -T shard2_2 mongosh --port 27025 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF