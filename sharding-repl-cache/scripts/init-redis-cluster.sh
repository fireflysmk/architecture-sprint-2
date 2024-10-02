docker compose exec -T redis_1 sh <<EOF
echo "yes" | redis-cli --cluster create 173.18.0.22:6379 173.18.0.23:6379 173.18.0.24:6379 173.18.0.25:6379 173.18.0.26:6379 173.18.0.27:6379 --cluster-replicas 1
EOF

docker compose exec -T redis_1 sh <<EOF
redis-cli cluster nodes
EOF