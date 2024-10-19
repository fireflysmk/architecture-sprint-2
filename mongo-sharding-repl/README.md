# Спринт 2 / Задание 3

В этом задании к решению второго задания добавляем по 2 реплики каждому из
шардов. Это новые контейнера с именами ```shard1a```, ```shard1b```,
```shard2a``` и ```shard2b```. Все эти контейнеры запускаются
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
Transactions:                  11539 hits
Response time:                  0.03 secs
Transaction rate:             192.35 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       11539
Failed transactions:               0
Longest transaction:            0.11
Shortest transaction:           0.00
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     56 hits
Response time:                  5.19 secs
Transaction rate:               0.93 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          56
Failed transactions:               0
Longest transaction:            7.09
Shortest transaction:           3.05
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  23121 hits
Response time:                  0.01 secs
Transaction rate:             385.41 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       23121
Failed transactions:               0
Longest transaction:            2.02
Shortest transaction:           0.00
```

## Проверка задания

Запускаем контейнеры:
```
$ ./sprint2.sh -t 3 -m start
Executing Task #3, working directory 'mongo-sharding-repl'
Staring containers...
[+] Running 18/18
 ✔ Network mongo-sharding-repl_app-network    Created                       0.3s
 ✔ Volume "mongo-sharding-repl_shard2b-data"  Created                       0.0s
 ✔ Volume "mongo-sharding-repl_router-data"   Created                       0.0s
 ✔ Volume "mongo-sharding-repl_shard2-data"   Created                       0.0s
 ✔ Volume "mongo-sharding-repl_shard2a-data"  Created                       0.0s
 ✔ Volume "mongo-sharding-repl_shard1-data"   Created                       0.0s
 ✔ Volume "mongo-sharding-repl_shard1a-data"  Created                       0.0s
 ✔ Volume "mongo-sharding-repl_shard1b-data"  Created                       0.0s
 ✔ Volume "mongo-sharding-repl_config-data"   Created                       0.0s
 ✔ Container shard2a                          Started                       0.1s
 ✔ Container shard1a                          Started                       0.1s
 ✔ Container shard2b                          Started                       0.1s
 ✔ Container mongos_router                    Started                       0.1s
 ✔ Container shard1b                          Started                       0.1s
 ✔ Container shard2                           Started                       0.1s
 ✔ Container shard1                           Started                       0.1s
 ✔ Container configSrv                        Started                       0.1s
 ✔ Container pymongo_api                      Started                       0.0s
Done
```

Инициализируем настройку кластера (обращаем внимание на изменение статуса контейнеров
с unhealthy на healthy):
```
$ ./sprint2.sh -t 3 -i
Executing Task #3, working directory 'mongo-sharding-repl'
Init DB config...
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                     PORTS
                   NAMES
336442fd61a9   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   6 minutes ago   Up 6 minutes               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
80f520693d04   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
914d687300f4   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27038->27038/tcp, :::27038->27038/tcp   shard1b
2001ac30b296   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27028->27028/tcp, :::27028->27028/tcp   shard1a
bee56468ccc0   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27039->27039/tcp, :::27039->27039/tcp   shard2b
6b4fb2d24727   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (unhealthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
0ab807f1d9ef   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27029->27029/tcp, :::27029->27029/tcp   shard2a
e44f87408746   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
ce52f9138b1d   mongo:latest               "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes (healthy)     27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
Give few seconds to configSrv to digest the change in its config...
Server configuration is complete!
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                   PORTS
                 NAMES
336442fd61a9   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   7 minutes ago   Up 6 minutes             0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
80f520693d04   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
914d687300f4   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27038->27038/tcp, :::27038->27038/tcp   shard1b
2001ac30b296   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27028->27028/tcp, :::27028->27028/tcp   shard1a
bee56468ccc0   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27039->27039/tcp, :::27039->27039/tcp   shard2b
6b4fb2d24727   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
0ab807f1d9ef   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27029->27029/tcp, :::27029->27029/tcp   shard2a
e44f87408746   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
ce52f9138b1d   mongo:latest               "docker-entrypoint.s…"   7 minutes ago   Up 6 minutes (healthy)   27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
Done
```

Список всех реплик:
```
$ ./sprint2.sh -t 3 -w rs_status
Executing Task #3, working directory 'mongo-sharding-repl'
Replicaset status
On shard1...
shard1 [direct: secondary] test>
>shard1:27018 -> SECONDARY
shard1a:27028 -> SECONDARY
shard1b:27038 -> PRIMARY

>
On shard2...
shard2 [direct: secondary] test>
>shard2:27019 -> SECONDARY
shard2a:27029 -> SECONDARY
shard2b:27039 -> PRIMARY

>Done
```

Инициализируем данные:
```
$ ./sprint2.sh -t 3 -r 2000
Executing Task #3, working directory 'mongo-sharding-repl'
Initialize DB with 2000 documents...
This collection has  2000  documents
Done
```

Проверяем коллекцию документов в БД:
```
$ ./sprint2.sh -t 3 -c
Executing Task #3, working directory 'mongo-sharding-repl'
Count documents in DB...
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2
Done
```

Проверим статус шардинга на сервере mongos_router:
```
$ ./sprint2.sh -t 3 -w sh_status
Executing Task #3, working directory 'mongo-sharding-repl'
Cheking status of sharding in the Mongo cluster at mongos_router...
[direct: mongos] test> shardingVersion
{ _id: 1, clusterId: ObjectId('67133cee033a81de4b213e77') }
---
shards
[
  {
    _id: 'shard1',
    host: 'shard1/shard1:27018,shard1a:27028,shard1b:27038',
    state: 1,
    topologyTime: Timestamp({ t: 1729314053, i: 9 }),
    replSetConfigVersion: Long('-1')
  },
  {
    _id: 'shard2',
    host: 'shard2/shard2:27019,shard2a:27029,shard2b:27039',
    state: 1,
    topologyTime: Timestamp({ t: 1729314054, i: 15 }),
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
  'Currently enabled': 'yes',
  'Currently running': 'no',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {}
  },
  {
    database: {
      _id: 'somedb',
      primary: 'shard1',
      version: {
        uuid: UUID('4383fc3a-5653-4e6f-808b-f8dcaa853df2'),
        timestamp: Timestamp({ t: 1729314055, i: 2 }),
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
[direct: mongos] test> Done
```

Выберем несколько документов с каждого шарда (это действие одновременно
сформирует файл urls.lst для использования в нагрузочном тесте):
```
$ ./sprint2.sh -t 3 -s 5
Executing Task #3, working directory 'mongo-sharding-repl'
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
$ ./sprint2.sh -t 3 -b 60
Executing Task #3, working directory 'mongo-sharding-repl'
Benchmarking...
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  11539 hits
Response time:                  0.03 secs
Transaction rate:             192.35 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       11539
Failed transactions:               0
Longest transaction:            0.11
Shortest transaction:           0.00
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     56 hits
Response time:                  5.19 secs
Transaction rate:               0.93 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          56
Failed transactions:               0
Longest transaction:            7.09
Shortest transaction:           3.05
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  23121 hits
Response time:                  0.01 secs
Transaction rate:             385.41 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       23121
Failed transactions:               0
Longest transaction:            2.02
Shortest transaction:           0.00
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 3 -m stop
Executing Task #3, working directory 'mongo-sharding-repl'
Stopping containers...
[+] Running 10/10
 ✔ Container shard2a                        Removed                        10.6s
 ✔ Container shard1a                        Removed                        12.1s
 ✔ Container shard1                         Removed                        11.3s
 ✔ Container shard2                         Removed                        12.4s
 ✔ Container shard2b                        Removed                        11.6s
 ✔ Container pymongo_api                    Removed                         1.4s
 ✔ Container configSrv                      Removed                         0.7s
 ✔ Container shard1b                        Removed                        12.3s
 ✔ Container mongos_router                  Removed                        11.1s
 ✔ Network mongo-sharding-repl_app-network  Removed                         0.7s
Done
```

Для чистоты эксперимента перед повторным запуском всех вышеперечисленных
действий на этом этапе рекомендуется удалить все файлы данных через
```docker volume prune```, ```docker volume ls```, ```docker volume rm ...```.