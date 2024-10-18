# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
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

## sprint2.sh

Этот скрипт будет использоваться для выполнения и проверки заданий этого спринта.
```
$ ./sprint2.sh -h
Usage:
  ./sprint2.sh -t <task_num> [-m <mode>] [-h] [-b] [-c] [-i] [-l] [-r num_doc]
Where
  -t task_num       -            task number from this sprint (1..6)
  -m mode           - (optional) containers' mode (one of 'up' or 'down')
  -b                - (optional) conduct benchmarks
  -c                - (optional) count number of documents in DB
  -i                - (optional) init DB configuration
  -l                - (optional) list container names
  -r num_doc        - (optional) recreate collection with num_doc documents
  -h                - (optional) this help
```