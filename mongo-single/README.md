# Спринт 2 / Задание 1

В этом задании просто создаем приложение ```pymongo-api``` и подключаем его к
MongoDB ```mongodb1```. Все это сделано на основании
[репозитория](https://github.com/Yandex-Practicum/architecture-sprint-2) и
запускается через ```compose.yaml``` в этом подкаталоге.

## Примечание

Для упрощения выполнения и проверки задания в корневом подкаталоге этого
репозитория создан скрипт ```sprint2.sh``` (см. описание в [README](../README.md#sprint2sh)).

## Метрики конфигурации

```
This collection has  2000  documents in total

ab -c 25 -t 20 http://localhost:8080/
Completed 5000 requests
Finished 6422 requests
Requests per second:    320.96 [#/sec] (mean)
  90%     95

ab -c 25 -t 20 http://localhost:8080/helloDoc/users
Finished 2 requests
Requests per second:    0.10 [#/sec] (mean)
  90%  19111
```

## Проверка задания

Запускаем контейнеры:
```
$ ./sprint2.sh -t 1 -m up
Executing Task #1, working directory 'mongo-single'
Staring containers...
[+] Running 2/2
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

Запускаем нагрузочный тест:
```
$ ./sprint2.sh -t 1 -b
Executing Task #1, working directory 'mongo-single'
Benchmarking...
ab -c 25 -t 20 http://localhost:8080/
Completed 5000 requests
Finished 6422 requests
Requests per second:    320.96 [#/sec] (mean)
  90%     95

ab -c 25 -t 20 http://localhost:8080/helloDoc/users
Finished 2 requests
Requests per second:    0.10 [#/sec] (mean)
  90%  19111
Done
```

Выключаем контейнеры:
```
$ ./sprint2.sh -t 1 -m down
Executing Task #1, working directory 'mongo-single'
Stopping containers...
[+] Running 3/3
 ✔ Container pymongo_api         Removed                                    1.5s
 ✔ Container mongodb1            Removed                                    0.6s
 ✔ Network mongo-single_default  Removed                                    0.7s
Done
```
