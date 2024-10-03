docker exec -it configSrv mongosh --port 27022 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27022" }
    ]
  }
); 
exit();
EOF
 

docker exec -it shard1 mongosh --port 27023 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27023" }
      ]
    }
); 

exit();
EOF

docker exec -it shard2 mongosh --port 27024 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27024" }
      ]
    }
  ); 
exit(); 
EOF

docker exec -it mongos_router mongosh --port 27025 <<EOF
sh.addShard( "shard1/shard1:27023");
sh.addShard( "shard2/shard2:27024");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i}); 
exit();
EOF 