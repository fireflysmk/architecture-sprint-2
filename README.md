# pymongo-api

Инструкции ниже работают для всех трёх заданий.

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем БД и наполняем её данными

```shell
./scripts/init-configsvr.sh
./scripts/init-shards.sh
./scripts/init-router.sh
./scripts/mongo-init.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080
