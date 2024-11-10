docker exec -it configSrv mongosh --port 27019

rs.initiate(
  {
    _id : "configSrv",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27019" }
    ]
  }
);

docker exec -it shard1 mongosh --port 27022

> rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27022" },
      ]
    }
);
> exit();

docker exec -it shard2 mongosh --port 27023

> rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2:27023" },
      ]
    }
);
> exit();

docker exec -it mongos_router mongosh --port 27017
sh.addShard( "shard1/shard1:27022");
sh.addShard( "shard2/shard2:27023");

> sh.enableSharding("somedb");
> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

> use somedb

> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

> db.helloDoc.countDocuments() 
> exit(); 