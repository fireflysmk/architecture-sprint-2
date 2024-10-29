# pymongo-api

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