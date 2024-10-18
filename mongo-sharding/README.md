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

## Метрики конфигурации

```
This collection has  2000  documents in total
This collection has  1016  documents on  shard1
This collection has  984  documents on  shard2

ab -c 25 -t 20 http://localhost:8080/
Finished 4617 requests
Requests per second:    230.78 [#/sec] (mean)
  90%    128

ab -c 25 -t 20 http://localhost:8080/helloDoc/users
Finished 3 requests
Requests per second:    0.13 [#/sec] (mean)
  90%  22828
```

## Проверка задания

Запускаем контейнеры:
```
./sprint2.sh -t 2 -m up
Executing Task #2, working directory 'mongo-sharding'
Staring containers...
[+] Running 6/6
 ✔ Network mongo-sharding_app-network  Created                              0.1s
 ✔ Container configSrv                 Started                              0.1s
 ✔ Container mongos_router             Started                              0.1s
 ✔ Container shard1                    Started                              0.1s
 ✔ Container shard2                    Started                              0.1s
 ✔ Container pymongo_api               Started                              0.1s
Done```

Инициализируем настройку кластера:
```
$ ./sprint2.sh -t 2 -i
Executing Task #2, working directory 'mongo-sharding'
Init DB config...
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                     PORTS
                   NAMES
c1f23dde61aa   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   2 minutes ago   Up 2 minutes               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
b99d0ef63dfb   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)     27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
4c5a31938efb   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (unhealthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
3fd61c350cc4   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (unhealthy)   27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
9ea95ec518cc   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (unhealthy)   27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
test> ... ... ... ... ... ... ... ... {
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1729230283, i: 1 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1729230283, i: 1 })
}
config_server [direct: secondary] test> Give few seconds to configSrv to digest the change in its config...
MongoServerError[AlreadyInitialized]: already initialized. ... Uncaught
shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb> { ok: 1, dropped: 'somedb' }
MongoServerError[AlreadyInitialized]: already initialized test> ... ... ... ... ... ... ... ... Uncaught
shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb> { ok: 1, dropped: 'somedb' }
shard2 [direct: primary] somedb> Current Mongosh Log ID:        6711f5d75d711e36d3fe6910
Connecting to:          mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.2
Using MongoDB:          8.0.1
Using Mongosh:          2.3.2

For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/

------
   The server generated these startup warnings when booting
   2024-10-18T05:42:37.884+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
------

[direct: mongos] test> {
  shardAdded: 'shard1',
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1729230296, i: 22 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1729230296, i: 22 })
}
[direct: mongos] test> {
  shardAdded: 'shard2',
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1729230296, i: 45 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1729230296, i: 39 })
}
[direct: mongos] test>
[direct: mongos] test> {
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1729230296, i: 52 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1729230296, i: 50 })
}
[direct: mongos] test> {
  collectionsharded: 'somedb.helloDoc',
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1729230296, i: 101 }),
    signature: {
      hash: Binary.createFromBase64('AAAAAAAAAAAAAAAAAAAAAAAAAAA=', 0),
      keyId: Long('0')
    }
  },
  operationTime: Timestamp({ t: 1729230296, i: 101 })
}
[direct: mongos] test> Server configuration is complete!
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                   PORTS
                 NAMES
c1f23dde61aa   kazhem/pymongo_api:1.0.0   "uvicorn app:app --h…"   2 minutes ago   Up 2 minutes             0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                  pymongo_api
b99d0ef63dfb   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27020->27020/tcp, :::27020->27020/tcp   configSrv
4c5a31938efb   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp              mongos_router
3fd61c350cc4   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27018->27018/tcp, :::27018->27018/tcp   shard1
9ea95ec518cc   mongo:latest               "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes (healthy)   27017/tcp, 0.0.0.0:27019->27019/tcp, :::27019->27019/tcp   shard2
Done
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
Done```

Запускаем нагрузочный тест:
```
$ ./sprint2.sh -t 2 -b
Executing Task #2, working directory 'mongo-sharding'
Benchmarking...
ab -c 25 -t 20 http://localhost:8080/
Finished 4617 requests
Requests per second:    230.78 [#/sec] (mean)
  90%    128

ab -c 25 -t 20 http://localhost:8080/helloDoc/users
Finished 3 requests
Requests per second:    0.13 [#/sec] (mean)
  90%  22828
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 2 -m down
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
