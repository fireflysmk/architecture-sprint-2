echo "Initializing mongo cluster"
/bin/bash ./mongod-init.sh
echo "Initializing mongo cluster done"
sleep 30s

echo "Configuring mongo cluster"
/bin/bash ./configure_mongos.sh
sleep 30s
echo "Configuring mongo cluster done"

echo "Adding data"
/bin/bash ./add_data.sh
sleep 5s
echo "Adding data done"

echo "Initializing redis cluster"
/bin/bash ./init-redis-cluster.sh
sleep 5s
echo "Initializing redis cluster done"

echo "Check"
/bin/bash ./check.sh
sleep 5s
echo "Checked"