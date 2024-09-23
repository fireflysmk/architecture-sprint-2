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
# show doc count shard 2
###
docker-compose exec -T shard2 mongosh --port 27019 <<EOF
    use somedb;

    db.helloDoc.countDocuments();
EOF