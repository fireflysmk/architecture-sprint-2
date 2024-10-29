# pymongo-api
Схема доступна по ссылке: https://drive.google.com/file/d/1gwMXGBHWtWR1ulzUMwdzqZinfe7136S6/view?usp=sharing

## Задание 2. Шардирование
  Внутри проекта перейдите в директорию  mongo-sharding
  Она содержит файл - compose.yaml 
  Для его запуска введите комманду: docker-compose up -d
  После запуска, убедитесь что все сервисы успешно запустились 
  Затем нужно сделать конфигурацию и заполнить тестовыми данными 
  Для этого нужно вызвать скрипт (Нам потребуется GitBash)
  Открываем нашу директорию в GitBash и вводим комманду: ./scripts/init_sharding.sh
  Выполнение займет около 10-15 секунд. В конце должны увидеть результат комманды db.helloDoc.countDocuments()
  А именно число 1000; 
  После этого можем проводить необходимые тесты 
  
  
  
  
## Задание 3. Репликация
  Внутри проекта перейдите в директорию  mongo-sharding-repl (Дальше все шаги одинаковы с заданием 2)
  Она содержит файл - compose.yaml 
  Для его запуска введите комманду: docker-compose up -d
  После запуска, убедитесь что все сервисы успешно запустились 
  Затем нужно сделать конфигурацию и заполнить тестовыми данными 
  Для этого нужно вызвать скрипт (Нам потребуется GitBash)
  Открываем нашу директорию в GitBash и вводим комманду: ./scripts/init_sharding.sh
  Выполнение займет около 10-15 секунд. В конце должны увидеть результат комманды db.helloDoc.countDocuments()
  А именно число 1000; 
  После этого можем проводить необходимые тесты 
  
## Задание 4. Кэширование
  Внутри проекта перейдите в директорию  sharding-repl-cache (
  Она содержит файл - compose.yaml 
  Также у нас появилась новая папка - redis , которая содержит файл redis.conf для настройки redis в режиме cluster
  Для его запуска файла compose.yaml введите комманду: docker-compose up -d
  После запуска, убедитесь что все сервисы успешно запустились 
  Затем нужно сделать конфигурацию и заполнить тестовыми данными 
  Для этого нужно вызвать скрипт (Нам потребуется GitBash)
  Открываем нашу директорию в GitBash и вводим комманду: ./scripts/init_sharding.sh 
  В данном файле присутсвуют настройки для обьединения redis в cluster
  После ~10 секунд , он попросит доступ к конфигурации redis . Для этого нужно будет ввести в окно терминала "yes"
  Также были внесены изменения в сам проект, чтобы он поддерживал работу в кластерном режиме:
	а) - В папке api_app в файле requirements была добавлена зависимость redis-py-cluster[asyncio]==2.1.3
		И для ее совместимости была понижена версия  redis , а именно "redis==3.5.3"
	б) - Также в самом файле был изменен код проверки присутсвия поля REDIS_URL с
	if REDIS_URL:
		cache = cache
	else:
		cache = nocache
		
	на 
	
	if REDIS_URL:
		cache = cache
		redis_urls_list = REDIS_URLS.split(",")
		redis = RedisCluster(startup_nodes=[{"host": url.split(":")[0], "port": int(url.split(":")[1])} for url in redis_urls_list], decode_responses=True)
		FastAPICache.init(RedisBackend(redis), prefix="api:cache")
	else:
		cache = nocache
	(К сожалению я не владею python , поэтому этот кусок сгенерировал chatGpt)
  После этого можем проводить необходимые тесты
  1-й запрос идет около 1с , последующие <100мс
  
  