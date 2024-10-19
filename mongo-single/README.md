# Спринт 2 / Задание 1

В этом задании просто создаем приложение ```pymongo-api``` и подключаем его к
MongoDB ```mongodb1```. Все это сделано на основании
[репозитория](https://github.com/Yandex-Practicum/architecture-sprint-2) и
запускается через ```compose.yaml``` в этом подкаталоге.

## Примечание

Для упрощения выполнения и проверки задания в корневом подкаталоге этого
репозитория создан скрипт ```sprint2.sh``` (см. описание в [README](../README.md#sprint2sh)).

## Метрики этой конфигурации

```
This collection has  2000  documents in total

siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  18795 hits
Response time:                  0.02 secs
Transaction rate:             320.30 trans/sec
Throughput:                     0.12 MB/sec
Successful transactions:       18795
Failed transactions:               0
Longest transaction:            0.12
Shortest transaction:           0.00
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     53 hits
Response time:                  5.17 secs
Transaction rate:               0.91 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          53
Failed transactions:               0
Longest transaction:            8.09
Shortest transaction:           4.04
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  32379 hits
Response time:                  0.01 secs
Transaction rate:             554.15 trans/sec
Throughput:                     0.03 MB/sec
Successful transactions:       32379
Failed transactions:               0
Longest transaction:            0.21
Shortest transaction:           0.00
```

## Проверка задания

Запускаем контейнеры:
```
$ ./sprint2.sh -t 1 -m start
Executing Task #1, working directory 'mongo-single'
Staring containers...
[+] Running 4/4
 ✔ Network mongo-single_default                   Created                   0.2s
 ✔ Volume "mongo-single_mongodb1_data_container"  Created                   0.0s
 ✔ Container pymongo_api  Started                                           0.1s
 ✔ Container mongodb1     Started                                           0.6s
Done
```

Инициализируем данные:
```
$ ./sprint2.sh -t 1 -r 2000
Executing Task #1, working directory 'mongo-single'
Initialize DB with 2000 documents...
This collection has  2000  documents
Done
```

Проверяем коллекцию документов в БД:
```
$ ./sprint2.sh -t 1 -c
Executing Task #1, working directory 'mongo-single'
Count documents in DB...
This collection has  2000  documents in total
Done
```

Выберем несколько документов с каждого шарда (это действие одновременно
сформирует файл urls.lst для использования в нагрузочном тесте):
```
$ ./sprint2.sh -t 1 -s 10
Executing Task #1, working directory 'mongo-single'
Selecting data sample from each shard...
http://127.0.0.1:8080/helloDoc/users/ly0
http://127.0.0.1:8080/helloDoc/users/ly1
http://127.0.0.1:8080/helloDoc/users/ly2
http://127.0.0.1:8080/helloDoc/users/ly3
http://127.0.0.1:8080/helloDoc/users/ly4
http://127.0.0.1:8080/helloDoc/users/ly5
http://127.0.0.1:8080/helloDoc/users/ly6
http://127.0.0.1:8080/helloDoc/users/ly7
http://127.0.0.1:8080/helloDoc/users/ly8
http://127.0.0.1:8080/helloDoc/users/ly9
Done
```

Запускаем нагрузочный тест:
```
$ ./sprint2.sh -t 1 -b 60
Executing Task #1, working directory 'mongo-single'
Benchmarking...
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/
Transactions:                  18795 hits
Response time:                  0.02 secs
Transaction rate:             320.30 trans/sec
Throughput:                     0.12 MB/sec
Successful transactions:       18795
Failed transactions:               0
Longest transaction:            0.12
Shortest transaction:           0.00
siege -b -c 5 -t 60s --rc=/dev/null http://127.0.0.1:8080/helloDoc/users
Transactions:                     53 hits
Response time:                  5.17 secs
Transaction rate:               0.91 trans/sec
Throughput:                     0.05 MB/sec
Successful transactions:          53
Failed transactions:               0
Longest transaction:            8.09
Shortest transaction:           4.04
siege -b -c 5 -t 60s --rc=/dev/null --file=/home/boris/repos/architecture-sprint-2/./urls.lst
Transactions:                  32379 hits
Response time:                  0.01 secs
Transaction rate:             554.15 trans/sec
Throughput:                     0.03 MB/sec
Successful transactions:       32379
Failed transactions:               0
Longest transaction:            0.21
Shortest transaction:           0.00
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 1 -m stop
Executing Task #1, working directory 'mongo-single'
Stopping containers...
[+] Running 3/3
 ✔ Container pymongo_api         Removed                                    1.5s
 ✔ Container mongodb1            Removed                                    0.6s
 ✔ Network mongo-single_default  Removed                                    0.7s
Done
```

Для чистоты эксперимента перед повторным запуском всех вышеперечисленных
действий на этом этапе рекомендуется удалить все файлы данных через
```docker volume prune```, ```docker volume ls```, ```docker volume rm ...```.