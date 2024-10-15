# sharding-repl-cache

## Как запустить

Запускаем mongodb, два роутера, конфигурационный сервер и две шарды

```shell
docker-compose up -d
```

Подключаемся к серверу конфигурации и делаем инициализацию

```shell
docker exec -it configServer mongosh

rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configServer" }
    ]
  }
);
exit();
```

Подключимся к первой реплике

```shell
docker exec -it repl11 mongosh

rs.initiate({_id: "rs0", members: [{_id: 0, host: "repl11"}, {_id: 1, host: "repl12"}, {_id: 2, host: "repl13"}]});
exit();

```

```shell
docker exec -it repl21 mongosh

rs.initiate({_id: "rs1", members: [{_id: 0, host: "repl21"},{_id: 1, host: "repl22"},{_id: 2, host: "repl23"}]});
exit();
```
Инициализируем роутер и наполняем шарды данными:

```shell
docker exec -it mongos_router1 mongosh

sh.addShard( "rs0/repl11,repl12,repl13");
sh.addShard( "rs1/repl21,repl22,repl23");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"testname"+i})
db.helloDoc.countDocuments() 
exit();
```

Выведем количество документов по первой реплике

```shell
docker compose exec -T repl11 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker compose exec -T repl12 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker compose exec -T repl13 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker compose exec -T repl21 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker compose exec -T repl22 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker compose exec -T repl23 mongosh
use somedb
db.helloDoc.countDocuments();
exit();
 ```

```shell
docker exec -it repl12 mongosh
rs.status().members.length;
exit();
```