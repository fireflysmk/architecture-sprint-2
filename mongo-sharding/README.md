# Спринт 2 / Задание 2

В этом задании просто создаем приложение ```pymongo-api``` и подключаем его к
MongoDB. В данном случае это уже клстер, состящий из ```mongos_router```,
```shard1```, ```shard2``` и ```configSrv```. Все эти контейнеры запускаются
через ```compose.yaml``` в этом подкаталоге. Для упрощения выполнения заданий
содержимое подкаталога ```api_app``` с приложением не копируется, а просто
создается symbolic link на оригинал.

## Примечание

Для упрощения выполнения и проверки задания в корневом подкаталоге этого
репозитория создан скрипт ```sprint2.sh``` (см. описание в [README](../README.md#sprint2sh)).

## Метрики этой конфигурации

```
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2

siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  12079 hits
Response time:                  0.02 secs
Transaction rate:             209.52 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       12079
Failed transactions:               0
Longest transaction:            0.10
Shortest transaction:           0.01
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     56 hits
Response time:                  5.16 secs
Transaction rate:               0.95 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          56
Failed transactions:               0
Longest transaction:            8.08
Shortest transaction:           4.04
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  25027 hits
Response time:                  0.01 secs
Transaction rate:             428.40 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       25027
Failed transactions:               0
Longest transaction:            2.52
Shortest transaction:           0.00
```

## Проверка задания

Запускаем контейнеры:
```
$ ./sprint2.sh -t 2 -m start
Executing Task #2, working directory 'mongo-sharding'
Staring containers...
[+] Running 10/10
 ✔ Network mongo-sharding_app-network   Created                             0.3s
 ✔ Volume "mongo-sharding_shard1-data"  Created                             0.0s
 ✔ Volume "mongo-sharding_shard2-data"  Created                             0.0s
 ✔ Volume "mongo-sharding_config-data"  Created                             0.0s
 ✔ Volume "mongo-sharding_router-data"  Created                             0.0s
 ✔ Container shard2                     Started                             0.1s
 ✔ Container configSrv                  Started                             0.1s
 ✔ Container mongos_router              Started                             0.1s
 ✔ Container shard1                     Started                             0.1s
 ✔ Container pymongo_api                Started                             0.1s
Done
```

Инициализируем настройку кластера (обращаем внимание на изменение статуса контейнеров
с unhealthy на healthy):
```
$ ./sprint2.sh -t 2 -i
Executing Task #2, working directory 'mongo-sharding'
Init DB config...
CONTAINER ID   IMAGE                      COMMAND                  CREATED              STATUS                          PORTS
                             NAMES
3de22007460f   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   About a minute ago   Up About a minute               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
839c5a7ef3e8   mongo:latest               "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)     27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
b3c1a9b4e119   mongo:latest               "docker-entrypoint.s…"   About a minute ago   Up About a minute (unhealthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
a8ee0da5e785   mongo:latest               "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)     27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
e73b6f61ff34   mongo:latest               "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)     27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
Give few seconds to configSrv to digest the change in its config...
Server configuration is complete!
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                   PORTS
                 NAMES
3de22007460f   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   2 minutes ago   Up 2 minutes             0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
839c5a7ef3e8   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
b3c1a9b4e119   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
a8ee0da5e785   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
e73b6f61ff34   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
Done
```

Список всех реплик:
```
$ ./sprint2.sh -t 2 -w rs_status
Executing Task #2, working directory 'mongo-sharding'
Replicaset status
On shard1...
shard1 [direct: primary] test>
>shard1:27018 -> PRIMARY

>
On shard2...
shard2 [direct: primary] test>
>shard2:27019 -> PRIMARY

>Done
```

Инициализируем данные:
```
$ ./sprint2.sh -t 2 -r 2000
Executing Task #2, working directory 'mongo-sharding'
Initialize DB with 2000 documents...
This collection has  2000  documents
Done
```

Проверяем коллекцию документов в БД:
```
$ ./sprint2.sh -t 2 -c
Executing Task #2, working directory 'mongo-sharding'
Count documents in DB...
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2
Done
```

Проверим статус шардинга на сервере mongos_router:
```
$ ./sprint2.sh -t 2 -w sh_status
Executing Task #2, working directory 'mongo-sharding'
Cheking status of sharding in the Mongo cluster at configSrv...
config_server [direct: primary] test> Warning: MongoshWarning: [SHAPI-10003] You are not connected to a mongos. This command may not work as expected.
shardingVersion
{ _id: 1, clusterId: ObjectId('67132b0c3e0759b3538bf573') }
---
shards
[
  {
    _id: 'shard1',
    host: 'shard1/shard1:27018',
    state: 1,
    topologyTime: Timestamp({ t: 1729309463, i: 10 }),
    replSetConfigVersion: Long('-1')
  },
  {
    _id: 'shard2',
    host: 'shard2/shard2:27019',
    state: 1,
    topologyTime: Timestamp({ t: 1729309464, i: 9 }),
    replSetConfigVersion: Long('-1')
  }
]
---
active mongoses
[ { '8.0.1': 1 } ]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently running': 'unknown',
  'Currently enabled': 'yes',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {
      'config.system.sessions': {
        shardKey: { _id: 1 },
        unique: false,
        balancing: true,
        chunkMetadata: [ { shard: 'shard1', nChunks: 1 } ],
        chunks: [
          { min: { _id: MinKey() }, max: { _id: MaxKey() }, 'on shard': 'shard1', 'last modified': Timestamp({ t: 1, i: 0 }) }
        ],
        tags: []
      }
    }
  },
  {
    database: {
      _id: 'somedb',
      primary: 'shard1',
      version: {
        uuid: UUID('e86d7816-50b3-40a4-b855-be70c5d32623'),
        timestamp: Timestamp({ t: 1729309464, i: 26 }),
        lastMod: 1
      }
    },
    collections: {
      'somedb.helloDoc': {
        shardKey: { name: 'hashed' },
        unique: false,
        balancing: true,
        chunkMetadata: [
          { shard: 'shard1', nChunks: 1 },
          { shard: 'shard2', nChunks: 1 }
        ],
        chunks: [
          { min: { name: MinKey() }, max: { name: Long('0') }, 'on shard': 'shard2', 'last modified': Timestamp({ t: 1, i: 0 }) },
          { min: { name: Long('0') }, max: { name: MaxKey() }, 'on shard': 'shard1', 'last modified': Timestamp({ t: 1, i: 1 }) }
        ],
        tags: []
      }
    }
  }
]
config_server [direct: primary] test> Done
```

Выберем несколько документов с каждого шарда (это действие одновременно
сформирует файл urls.lst для использования в нагрузочном тесте):
```
$ ./sprint2.sh -t 2 -s 5
Executing Task #2, working directory 'mongo-sharding'
Selecting data sample from each shard...
Some documents on shard1:
http://127.0.0.1:8080/helloDoc/users/ly0
http://127.0.0.1:8080/helloDoc/users/ly1
http://127.0.0.1:8080/helloDoc/users/ly2
http://127.0.0.1:8080/helloDoc/users/ly3
http://127.0.0.1:8080/helloDoc/users/ly4
Some documents on shard2:
http://127.0.0.1:8080/helloDoc/users/ly6
http://127.0.0.1:8080/helloDoc/users/ly7
http://127.0.0.1:8080/helloDoc/users/ly9
http://127.0.0.1:8080/helloDoc/users/ly11
http://127.0.0.1:8080/helloDoc/users/ly12
Done
```

Запускаем нагрузочный тест:
```
$ ./sprint2.sh -t 2 -b 60
Executing Task #2, working directory 'mongo-sharding'
Benchmarking...
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  12079 hits
Response time:                  0.02 secs
Transaction rate:             209.52 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       12079
Failed transactions:               0
Longest transaction:            0.10
Shortest transaction:           0.01
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     56 hits
Response time:                  5.16 secs
Transaction rate:               0.95 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          56
Failed transactions:               0
Longest transaction:            8.08
Shortest transaction:           4.04
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  25027 hits
Response time:                  0.01 secs
Transaction rate:             428.40 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       25027
Failed transactions:               0
Longest transaction:            2.52
Shortest transaction:           0.00
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 2 -m stop
Executing Task #2, working directory 'mongo-sharding'
Stopping containers...
[+] Running 6/6
 ✔ Container configSrv                 Removed                              1.6s
 ✔ Container shard1                    Removed                              1.2s
 ✔ Container pymongo_api               Removed                              2.2s
 ✔ Container shard2                    Removed                              1.7s
 ✔ Container mongos_router             Removed                             10.7s
 ✔ Network mongo-sharding_app-network  Removed                              0.7s
Done
```

Для чистоты эксперимента перед повторным запуском всех вышеперечисленных
действий на этом этапе рекомендуется удалить все файлы данных через
```docker volume prune```, ```docker volume ls```, ```docker volume rm ...```.