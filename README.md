# MongoDB Sharded Cluster with Docker Compose

Этот проект разворачивает MongoDB шардинговую кластерную архитектуру, включая конфигурационный сервер, шарды с репликационными наборами, маршрутизатор (`mongos`) и Redis. Все компоненты запускаются с помощью `docker-compose`.

---

## Содержание
- [Требования](#требования)
- [Структура проекта](#структура-проекта)
- [Как запустить](#как-запустить)
- [Описание сервисов](#описание-сервисов)

---

## Требования
Перед запуском убедитесь, что на вашем компьютере установлены:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

---

## Структура проекта
- **`docker-compose.yml`**: Основной файл для описания сервисов.
- **`scripts/mongo-init.sh`**: Скрипт для инициализации репликационных наборов и настройки шардинга.
- **`redis/redis.conf`**: Конфигурационный файл для Redis.

---

## Как запустить

1. **Клонировать репозиторий**
   ```bash
   git clone <url_вашего_репозитория>
   cd <имя_папки>

2. **Запустить контейнеры**

   ```bash
   docker-compose up -d


3.	**Подождать инициализации**

Вся инфраструктура автоматически поднимется и будет инициализирована, включая репликационные наборы и шардирование. Для проверки статуса выполнения можно просмотреть логи:

```bash
   docker-compose logs
```
4. **Заполнить данными**

    ```bash
   docker exec -it mongos_router mongosh --port 27020
    ```
   
    ```bash
   use somedb
    ```
   
     ```bash
   for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
    ```
   
5. **Проверить работоспособность**

 •	MongoDB маршрутизатор доступен по адресу localhost:27020.
 •	Redis доступен по порту 6379.

## Описание сервисов

Конфигурационный сервер (configSrv)

	•	Назначение: Управляет метаданными шардинга.
	•	Порт: 27017
	•	Флаги запуска:
	•	--configsvr: Запуск в режиме конфигурации.
	•	--replSet config_server: Репликационный набор для надежности.

Шарды

Shard 1 (shard1) и его реплики

	•	Порты:
	•	Основной: 27018
	•	Реплики: 27021, 27022
	•	Флаги запуска:
	•	--shardsvr: Запуск в режиме шарда.
	•	--replSet shard1: Репликационный набор.

Shard 2 (shard2) и его реплики

	•	Порты:
	•	Основной: 27019
	•	Реплики: 27023, 27024
	•	Флаги запуска:
	•	--shardsvr: Запуск в режиме шарда.
	•	--replSet shard2: Репликационный набор.

Маршрутизатор (mongos_router)

	•	Назначение: Упрощает доступ к шардинговой архитектуре.
	•	Порт: 27020
	•	Флаги запуска:
	•	--configdb config_server/configSrv:27017: Указывает на конфигурационный сервер.
	•	--bind_ip_all: Доступ из любой сети.

Redis

	•	Назначение: Сервис для кеширования.
	•	Порт: 6379
	•	Конфигурация: Использует файл redis/redis.conf.

Сервис инициализации (init)

	•	Назначение: Выполняет инициализацию кластера:
	•	Настраивает репликационные наборы.
	•	Добавляет шарды в конфигурацию.
	•	Скрипт запуска: scripts/mongo-init.sh

Полезные команды

Остановить контейнеры

```bash
docker-compose down
```
Посмотреть логи конкретного контейнера

```bash
docker logs <имя_контейнера>
```
Перезапустить сервис

```bash
docker-compose restart <имя_сервиса>
```

Замечания

1. Сетевые настройки:
Все сервисы подключены к сети app-network с диапазоном IP-адресов 173.17.0.0/16.
2.	Проверка MongoDB:
Для выполнения команд можно подключаться через mongosh:

mongosh --host localhost:27020

Используйте команду sh.status() для просмотра текущего состояния шардинга.

