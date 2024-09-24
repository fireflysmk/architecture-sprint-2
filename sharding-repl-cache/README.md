# Задание 1

# Задание 2

## Шардирование

### Инициализация сервера конфигурации

```bash
docker-compose exec -it configSrv mongosh --port 27017
```

```bash
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
```

### Инициализаци реплик

#### Шард 1

```bash
docker-compose exec -it shard1 mongosh --port 27018
```

```bash
rs.initiate({_id: "shard1", members: [
{_id: 0, host: "shard1:27018"},
{_id: 1, host: "shard1_2:27021"},
{_id: 2, host: "shard1_3:27022"}
]})
```

#### Шард 2

```bash
docker-compose exec -it shard2 mongosh --port 27019
```

```bash
rs.initiate({_id: "shard2", members: [
{_id: 0, host: "shard2:27019"},
{_id: 1, host: "shard2_2:27023"},
{_id: 2, host: "shard2_3:27024"}
]})
```


### Инициализация роутера

```bash
docker-compose exec -it mongos_router mongosh --port 27020
```

```bash
sh.addShard( "shard1/shard1:27018");
```

```bash
sh.addShard( "shard2/shard2:27019");
```

```bash
sh.enableSharding("somedb");
```

```bash
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
```

```bash
use somedb
```

```bash
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
```

```bash
db.helloDoc.countDocuments()
```

### Проверка в шардах

#### Шард 1

```bash
docker-compose exec -it shard1 mongosh --port 27018
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

##### Реплика 2

```bash
docker-compose exec -it shard1 mongosh --port 27021
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

##### Реплика 3

```bash
docker-compose exec -it shard1 mongosh --port 27022
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

#### Шард 2

```bash
docker-compose exec -it shard2 mongosh --port 27019
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

##### Реплика 2

```bash
docker-compose exec -it shard2 mongosh --port 27023
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

##### Реплика 3

```bash
docker-compose exec -it shard2 mongosh --port 27024
```

```bash
use somedb;
db.helloDoc.countDocuments();
```

### Запуск приложения

```bash
docker-compose up -d pymongo_api
```

Проверка [http://localhost:8080/](http://localhost:8080/)

