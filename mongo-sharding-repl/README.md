# mongo-sharding-repl

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем Сonfig Service, инициализируем shard1, shard2, добавляем шарды, заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

Смотрим общее кол-во документов в бд и на шардах

```shell
./scripts/mongo-show-count-docs.sh
```

Смотрим общее кол-во реплик

```shell
./scripts/mongo-show-count-repl.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs