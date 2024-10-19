# Спринт 2 / Задание 4

В этом задании к решению третьего задания добавляем сервис ```redis```.
Как и ранее, для упрощения выполнения заданий содержимое подкаталога
```api_app``` с приложением не копируется, а просто создается symbolic link
на оригинал.

До текущего момента мы просто занимались иасштабированием слоя БД и повышали его
отказоустойчивость. Теперь с добавлением кэш сервера займёмся повышением
производительности приложения.

## Примечание

Для упрощения выполнения и проверки задания в корневом подкаталоге этого
репозитория создан скрипт ```sprint2.sh``` (см. описание в [README](../README.md#sprint2sh)).

## Метрики этой конфигурации

```
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2

siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  11499 hits
Response time:                  0.03 secs
Transaction rate:             193.72 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       11499
Failed transactions:               0
Longest transaction:            0.09
Shortest transaction:           0.01
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                   8248 hits
Response time:                  0.04 secs
Transaction rate:             137.51 trans/sec
Throughput:                     7.82 MB/sec
Successful transactions:        8248
Failed transactions:               0
Longest transaction:            5.15
Shortest transaction:           0.02
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  25049 hits
Response time:                  0.01 secs
Transaction rate:             417.62 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       25049
Failed transactions:               0
Longest transaction:            0.05
Shortest transaction:           0.00
```

## Проверка задания

Запускаем контейнеры:
```
$ ./sprint2.sh -t 4 -m start
Executing Task #4, working directory 'sharding-repl-cache'
Staring containers...
[+] Running 20/20
 ✔ Network sharding-repl-cache_app-network    Created                       0.2s
 ✔ Volume "sharding-repl-cache_router-data"   Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard1b-data"  Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard2b-data"  Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard2a-data"  Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard1-data"   Created                       0.0s
 ✔ Volume "sharding-repl-cache_config-data"   Created                       0.0s
 ✔ Volume "sharding-repl-cache_redis_1_data"  Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard1a-data"  Created                       0.0s
 ✔ Volume "sharding-repl-cache_shard2-data"   Created                       0.0s
 ✔ Container shard2b                          Started                       0.1s
 ✔ Container redis_1                          Started                       0.1s
 ✔ Container configSrv                        Started                       0.2s
 ✔ Container mongos_router                    Started                       0.2s
 ✔ Container shard2a                          Started                       0.2s
 ✔ Container shard1                           Started                       0.1s
 ✔ Container shard2                           Started                       0.2s
 ✔ Container shard1a                          Started                       0.1s
 ✔ Container shard1b                          Started                       0.2s
 ✔ Container pymongo_api                      Started                       0.0s
Done
```

Инициализируем настройку кластера (обращаем внимание на изменение статуса контейнеров
с unhealthy на healthy):
```
$ ./sprint2.sh -t 4 -i
Executing Task #4, working directory 'sharding-repl-cache'
Init DB config...
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                     PORTS
                   NAMES
1c4f643b0053   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   2 minutes ago   Up 2 minutes               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
7d79e7569c8b   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
7ebe3c673624   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27029->27029/tcp, :::27029->27029/tcp   shard2a
1a2af1c370f1   redis:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes               0.0.0.0:32775->6379/tcp, :::32775->6379/tcp                redis_1
0483fa2ad859   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27028->27028/tcp, :::27028->27028/tcp   shard1a
09c5f2c7c337   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
872059ac7833   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
adb3039d3194   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27038->27038/tcp, :::27038->27038/tcp   shard1b
14b7f3f5fffd   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27039->27039/tcp, :::27039->27039/tcp   shard2b
6316d7cb70cc   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (unhealthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
Give few seconds to configSrv to digest the change in its config...
Server configuration is complete!
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                   PORTS
                 NAMES
1c4f643b0053   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   3 minutes ago   Up 3 minutes             0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
7d79e7569c8b   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
7ebe3c673624   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27029->27029/tcp, :::27029->27029/tcp   shard2a
1a2af1c370f1   redis:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes             0.0.0.0:32775->6379/tcp, :::32775->6379/tcp                redis_1
0483fa2ad859   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27028->27028/tcp, :::27028->27028/tcp   shard1a
09c5f2c7c337   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
872059ac7833   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
adb3039d3194   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27038->27038/tcp, :::27038->27038/tcp   shard1b
14b7f3f5fffd   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   27017/tcp, 0.0.0.0:27039->27039/tcp, :::27039->27039/tcp   shard2b
6316d7cb70cc   mongo:latest               "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes (healthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
Done
```

Список всех реплик:
```
$ ./sprint2.sh -t 4 -w rs_status
Executing Task #4, working directory 'sharding-repl-cache'
Replicaset status
On shard1...
shard1 [direct: secondary] test>
>shard1:27018 -> SECONDARY
shard1a:27028 -> SECONDARY
shard1b:27038 -> PRIMARY

>
On shard2...
shard2 [direct: primary] test>
>shard2:27019 -> PRIMARY
shard2a:27029 -> SECONDARY
shard2b:27039 -> SECONDARY

>Done
```

Инициализируем данные:
```
$ ./sprint2.sh -t 4 -r 2000
Executing Task #4, working directory 'sharding-repl-cache'
Initialize DB with 2000 documents...
This collection has  2000  documents
Done
```

Проверяем коллекцию документов в БД:
```
$ ./sprint2.sh -t 4 -c
Executing Task #4, working directory 'sharding-repl-cache'
Count documents in DB...
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2
Done
```

Проверим статус шардинга на сервере mongos_router:
```
$ ./sprint2.sh -t 4 -w sh_status
Executing Task #4, working directory 'sharding-repl-cache'
Cheking status of sharding in the Mongo cluster at mongos_router...
[direct: mongos] test> shardingVersion
{ _id: 1, clusterId: ObjectId('67134433b699a42e71d5b215') }
---
shards
[
  {
    _id: 'shard1',
    host: 'shard1/shard1:27018,shard1a:27028,shard1b:27038',
    state: 1,
    topologyTime: Timestamp({ t: 1729315914, i: 9 }),
    replSetConfigVersion: Long('-1')
  },
  {
    _id: 'shard2',
    host: 'shard2/shard2:27019,shard2a:27029,shard2b:27039',
    state: 1,
    topologyTime: Timestamp({ t: 1729315915, i: 8 }),
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
      primary: 'shard2',
      version: {
        uuid: UUID('1d0342bc-3f01-4ecb-aa2b-a1b56e163edc'),
        timestamp: Timestamp({ t: 1729315915, i: 25 }),
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
$ ./sprint2.sh -t 4 -s 5
Executing Task #4, working directory 'sharding-repl-cache'
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
$ ./sprint2.sh -t 4 -b 60
Executing Task #4, working directory 'sharding-repl-cache'
Benchmarking...
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  11499 hits
Response time:                  0.03 secs
Transaction rate:             193.72 trans/sec
Throughput:                     0.09 MB/sec
Successful transactions:       11499
Failed transactions:               0
Longest transaction:            0.09
Shortest transaction:           0.01
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                   8248 hits
Response time:                  0.04 secs
Transaction rate:             137.51 trans/sec
Throughput:                     7.82 MB/sec
Successful transactions:        8248
Failed transactions:               0
Longest transaction:            5.15
Shortest transaction:           0.02
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  25049 hits
Response time:                  0.01 secs
Transaction rate:             417.62 trans/sec
Throughput:                     0.02 MB/sec
Successful transactions:       25049
Failed transactions:               0
Longest transaction:            0.05
Shortest transaction:           0.00
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 4 -m stop
Executing Task #4, working directory 'sharding-repl-cache'
Stopping containers...
[+] Running 11/11
 ✔ Container pymongo_api                    Removed                         1.7s
 ✔ Container shard1a                        Removed                        11.3s
 ✔ Container configSrv                      Removed                         1.5s
 ✔ Container redis_1                        Removed                         1.2s
 ✔ Container shard2b                        Removed                        12.4s
 ✔ Container shard2a                        Removed                        12.0s
 ✔ Container shard2                         Removed                        12.1s
 ✔ Container shard1b                        Removed                        10.9s
 ✔ Container shard1                         Removed                        11.6s
 ✔ Container mongos_router                  Removed                        10.9s
 ✔ Network sharding-repl-cache_app-network  Removed                         0.8s
Done
```

Для чистоты эксперимента перед повторным запуском всех вышеперечисленных
действий на этом этапе рекомендуется удалить все файлы данных через
```docker volume rm $(docker volume ls -qf dangling=true)``` (если это
единственный набор контейнеров в Вашем Docker).