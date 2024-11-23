# pymongo-api

Для реализации шардированного варианта приложения реализована упрощенная схема с хэшированной стратегией сегментирования. 
Схема включает: 1 роутер, 1 сервер конфигурации и 2 шарда, ссылка на draw.io:

https://drive.google.com/file/d/1Yd0LxC7VE9Yqa9HL5vOvSke4Psv8tViy/view?usp=sharing


## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

Очистка базы данных

```shell
./scripts/db-drop.sh
```

## Как проверить

### Рузультат выполнения в shell

После запуска скрипта консоль выведет общее количество документов (1000) и количесво в каждом шарде.

```shell
[direct: mongos] somedb>
[direct: mongos] somedb> 1000
[direct: mongos] somedb> shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb>
shard1 [direct: primary] somedb> 492
shard1 [direct: primary] somedb> shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb>
shard2 [direct: primary] somedb> 508
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