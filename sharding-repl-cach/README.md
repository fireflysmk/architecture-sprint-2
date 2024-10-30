# Комментарии по обновленному compose.yaml:

## 1. Шардирование

configsrv – конфигурационный сервер, который управляет метаданными о шардировании. Использует порт 27017.

shard1 и shard2 – два шардированных набора для распределения данных, настроенные на порты 27018 и 27019 соответственно.

mongos – маршрутизатор, работающий на порту 27020, через который будут проходить запросы к MongoDB. Настройки pymongo_api 
перенаправлены на этот порт.

pymongo_api – микросервис приложения, который теперь обращается к MongoDB через mongos для работы с шардами.

## 2. Репликация

В каждом шарде настроена репликация с одной основной и двумя вторичными нодами.

shard1-primary, shard1-secondary1, shard1-secondary2 — инстансы для первого шарда

shard2-primary, shard2-secondary1, shard2-secondary2 — инстансы для второго шарда

## 3. Кэширование

redis: добавлен Redis для кэширования, работающий на порту 6379. Контейнер Redis сохраняет данные на диск, используя appendonly yes.

pymongo_api: добавлены переменные окружения REDIS_HOST и REDIS_PORT для подключения к Redis.



# Как запустить

## 1. Собираем и запускаем контейнеры из репозитория 

```shell
docker compose up -d
```

## 2. Инициируем конфигурационный сервер

```shell
docker-compose exec -T configsrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [{ _id: 0, host: "configsrv:27017" }]
})
EOF
```
## 3. Создаем шарды и реплики

### Первый шард
```shell
docker-compose exec -T shard1-primary mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1ReplSet",
  members: [
    { _id: 0, host: "shard1-primary:27018" },
    { _id: 1, host: "shard1-secondary1:27018" },
    { _id: 2, host: "shard1-secondary2:27018" }
  ]
})
EOF
```
### Второй шард
```shell
docker-compose exec -T shard2-primary mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "shard2ReplSet",
  members: [
    { _id: 0, host: "shard2-primary:27019" },
    { _id: 1, host: "shard2-secondary1:27019" },
    { _id: 2, host: "shard2-secondary2:27019" }
  ]
})
EOF
```

## 4. Добавляем шарды в маршрутизатор mongos

```shell
docker-compose exec -T mongos mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1ReplSet/shard1-primary:27018")
sh.addShard("shard2ReplSet/shard2-primary:27019")
EOF
```
## 5. Создаем базу данных somedb и коллекцию helloDoc
```shell
docker-compose exec -T mongos mongosh --port 27020 --quiet <<EOF
use somedb
db.createCollection("helloDoc")
EOF
```

## 6. Заполняем mongodb данными

В файле mongo-init.sh указываем mongos вместо эксемпляра БД

Запускаем скрипт:

```shell
./scripts/mongo-init.sh
```

## 7. Запускаем приложение

http://localhost:8080



# Архитектурная схема 

https://drive.google.com/file/d/1k_CSo84BHUZ2YzyU4REFmnuSAUem4530/view?usp=sharing

