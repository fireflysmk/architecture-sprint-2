# Оглавление

- [Краткое описание изначального задания](#pymongo-api)
- [Главная цель заданий этого спринта](#главная-цель-заданий-этого-спринта)
- [Диаграмма Draw.io с описанием решений](#диаграмма)
- [Скрипт для облегчения жизни с выполнением и проверкой](#sprint2sh)
- [Задание 1](mongo-single/README.md)
- [Задание 2](mongo-sharding/README.md)
- [Задание 3](mongo-sharding-repl/README.md)
- [Задание 4](sharding-repl-cache/README.md)
- [Задание 5](sharding-repl-cache-apisix/README.md)


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

## Главная цель заданий этого спринта

В этом спринте мы изучили различные техники повышения производительности
приложения, которые могут использоваться на "административном" уровне. То есть
без внесения изменений в код самого приложения. К сожалению, в текстах и
упражнениях этого спринта была слабо подчеркнута немаловажная роль такого
подхода. Мы зачем-то создавали сервисы на Yandex Cloud, смотрели на картинку
с квадратиками новых виптуальных машин и связями между ними, но главного мы
так и не сделали - доказать, что эта игра действительно стоит свеч. Для того,
чтобы заполнить эту нишу знаний и будет использованы задания этого спринта.

Сразу скажу, что запускать все я буду под Windows 10 + WSL2 + Ubuntu 22.04 на
моем стареньком лаптопе, поэтому Ваши данные запросто могут отличаться от моих.

Для определения эффекта от внедрения каждого нового уровня (задания спринта)
будем выполнять нагрузочный тест с помощью инструмента ```siege```, который
умеет делать запросы по списку URL из файла, а этот файл будет сформирован
таким образом, чтобы запросы были распределены по всем участникам каждой
новой конфигурации. Наши нагрузочные тесты не будут супер научными с определением
перценталей. Будет учитываться просто 1 запуск с протяженностью в 1 минуту на
каждый из тестов.

## Диаграмма

Как и в предыдущем спринте для удобства предоставляется одна многостраничная
диаграмма [draw.io](https://github.com/bmironov/architecture-sprint-2/blob/solution/Sprint_02.drawio).

## sprint2.sh

Этот скрипт будет использоваться для выполнения и проверки заданий этого спринта.
```
$ ./sprint2.sh -h

Usage:
  ./sprint2.sh -t <task_num> [-m <mode>] [-h] [-b <seconds>] [-c] [-i] [-r <num_doc>] [-s <num_doc>] [-w <what_is>]
Where
  -t task_num -            task number from this sprint (1..6)
  -m mode     - (optional) containers' mode (one of 'start' or 'stop')
  -b seconds  - (optional) conduct benchmarks with duration of specified number of seconds
  -c          - (optional) count number of documents in DB
  -i          - (optional) init DB configuration
  -r num_doc  - (optional) recreate collection with num_doc documents
  -s num_doc  - (optional) select num_doc from each shard for better benchmarking
  -w what_is  - (optional) get an answer for 'what is'-kind of question

  -h          - (optional) this help

Supported 'what is'-kind of questions:
  rs_status   - replica set(s) status
  sh_status   - sharding status, according to router_server

```