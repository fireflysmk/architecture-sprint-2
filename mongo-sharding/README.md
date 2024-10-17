# mongo-sharding

## Как запустить

1. Запуск mongodb и приложения

```shell

docker compose up -d

```

2. Инициализация

```shell

./scripts/init.sh

```

3. Наполнение

```shell

./scripts/fill.sh

```

## Как проверить

1. Тест

```shell

./scripts/tests.sh

```

2. FastAPI

```shell

http://localhost:8080/docs

```