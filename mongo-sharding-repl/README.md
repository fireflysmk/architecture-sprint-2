# pymongo-api

Для реализации шардированного варианта с репликацией приложения реализована упрощенная схема с хэшированной стратегией сегментирования и тремя репликами на каждом шарде. 
Схема включает: 1 роутер, 1 сервер конфигурации и 2 шарда с тремя репликами в каждом, ссылка на draw.io:

https://drive.google.com/file/d/1DtlZUV0B0FKdAe5qVzqNcSVcwjM4ETIT/view?usp=sharing


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