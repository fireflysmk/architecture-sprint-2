данные шаги описаны и выполнялись в docker desktop (windows)

1. запускаем контейнер
docker-compose up -d 

2. инициализируем конфиг сервер и шарды

docker exec -it configSrv mongosh --port 27017 --eval '
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [
        { _id: 0, host: "configSrv:27017" },
        { _id: 1, host: "configSrv_secondary_1:27017" },
        { _id: 2, host: "configSrv_secondary_2:27017" }
    ]
})'

docker exec -it shard1 mongosh --port 27018 --eval '
rs.initiate({
    _id: "shard1",
    members: [
        { _id: 0, host: "shard1:27018" },
        { _id: 1, host: "shard1_secondary_1:27018" },
        { _id: 2, host: "shard1_secondary_2:27018" }
    ]
})
'
docker exec -it shard2 mongosh --port 27019 --eval '
rs.initiate({
    _id: "shard2",
    members: [
        { _id: 0, host: "shard2:27019" },
        { _id: 1, host: "shard2_secondary_1:27019" },
        { _id: 2, host: "shard2_secondary_2:27019" }
    ]
})
'

3. подключаемся к роутеру и заполняем данными

docker exec -it mongos_router mongosh --port 27020

sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )


use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})

db.helloDoc.countDocuments() 

4. для проверки данных на шардах:
docker exec -it shard1 mongosh --port 27018
use somedb;
db.helloDoc.countDocuments();
exit(); 

4.1 заходим на реплику, убеждаемся что отображает такое же кол-во документов что и на мастере:
docker exec -it shard1_secondary_1 mongosh --port 27018
use somedb;
db.helloDoc.countDocuments();
exit(); 