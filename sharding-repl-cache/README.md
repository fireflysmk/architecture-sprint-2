# pymongo-api

Для реализации шардированного варианта с репликацией и кэшированием реализована упрощенная схема с хэшированной стратегией сегментирования и тремя репликами на каждом шарде. Для временного хранения данных реализован сервис хэширования Redis в Single Node режиме. В приложении кэширование доступно для эндпоинта /<collection_name>/users
Схема включает: 1 роутер, 1 сервер конфигурации и 2 шарда с тремя репликами в каждом, 1 сервис хэширования, ссылка на draw.io:

https://drive.google.com/file/d/1h76DW9y2f82uBVmRDcxmS2nfHk3ApoDa/view?usp=sharing


## Что реализовано

В файле соmpose.yaml сфомирована реализация двух шардов mongo-db c тремя репликами в каждой.

Добавлен Single Node Redis, в инстансе приложения  ymongo_api прописана глобальная переменная REDIS_URL: "redis://redis_1:6379"

Добавлены скрипты запуска bash для инициализации контейнеров и вывода результатов в консоль.

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Проводим инициализацию системы

```shell
./scripts/mongo-init.sh
```

Наполняеи mongodb данными и выводим результаты в консоль

```shell
./scripts/load-output.sh
```

Очистка базы данных

```shell
./scripts/db-drop.sh
```


## Как проверить

### Рузультат выполнения в shell

После запуска скриптов консоль выведет общее количество документов (+1000), количесво реплик (3) и количество в каждом шарде.

```shell
[direct: mongos] somedb> NOTE: helloDoc count=1000
[direct: mongos] somedb> shard1 [direct: primary] test> OUTPUT: shard1 repl count=3
shard1 [direct: primary] test> shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb> NOTE: shard1_db1 doc count=492
shard1 [direct: primary] somedb> shard1 [direct: secondary] test> switched to db somedb
shard1 [direct: secondary] somedb> NOTE: shard1_db2 doc count=492
shard1 [direct: secondary] somedb> shard1 [direct: secondary] test> switched to db somedb
shard1 [direct: secondary] somedb> NOTE: shard1_db3 doc count=492
shard1 [direct: secondary] somedb> shard2 [direct: primary] test> 
shard2 [direct: primary] test> OUTPUT: shard2 repl count=3
shard2 [direct: primary] test> shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb> NOTE: shard2_db1 doc count=508
shard2 [direct: primary] somedb> shard2 [direct: secondary] test> switched to db somedb
shard2 [direct: secondary] somedb> NOTE: shard2_db2 doc count=508
shard2 [direct: secondary] somedb> shard2 [direct: secondary] test> switched to db somedb
shard2 [direct: secondary] somedb> NOTE: shard2_db3 doc count=508
```

Для проверки хэширования необходимо перейти в swagger 

swagger http://<ip виртуальной машины>:8080/docs

И в энедпоните POST создания пользователя выполнить запрос 

/<collection_name>/users

Далее в методе  GET /<collection_name>/users получить пользователя. 
Кэширование значительно увеличивает скорость отклика для повторных запросов, второй и последующие вызовы выполяются <100мс.
Сброс кэша происходит автоматически по таймингу.


### Если вы запускаете проект на локальной машине

Открыть в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs

