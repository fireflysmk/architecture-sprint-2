# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

## Инициализация сервера конфигурации

```shell
docker exec -it configSrv mongosh --port 27000
```

```mongosh
rs.initiate(
  {
    _id : "configSrv",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27000" }
    ]
  }
);
```

## Инициализация кластера sgard01

```shell
docker exec -it shard01-a  mongosh --port 27101
```

```mongosh
rs.initiate({_id: "shard01", members: [
{_id: 0, host: "shard01-a:27101"},
{_id: 1, host: "shard01-b:27102"},
{_id: 2, host: "shard01-c:27103"}
]}) 
```

## Инициализация кластера sgard02

```shell
docker exec -it shard01-a  mongosh --port 27101
```

```mongosh
rs.initiate({_id: "shard02", members: [
{_id: 0, host: "shard02-a:27201"},
{_id: 1, host: "shard02-b:27202"},
{_id: 2, host: "shard02-c:27203"}
]}) 
```

## Инициализация кластера роутера

```shell
docker exec -it mongos_router mongosh --port 27100
```

```mongosh
sh.addShard( "shard01/shard01-a:27101");
sh.addShard( "shard02/shard02-a:27201");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );
```

## Заполнение базы данными

```shell
docker exec -it mongos_router mongosh --port 27100
```

```mongosh
use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
```


## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

## Диаграмы
..\sprint2_pymongo\diagrams


