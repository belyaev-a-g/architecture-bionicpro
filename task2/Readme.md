
# Задание 2. Разработка сервиса отчётов
## Задача 1. Создать архитектуру решения для подготовки и получения отчётов.


![Внедрение ETL](BionicPRO_task2.png)

## Задача 2. Разработать Airflow DAG и настроить его на запуск по расписанию.
Созданы 2 OLTP БД на Postgresql.  
crm_db - имитирует БД с CRM.  
telemetry_db - имитируют БД с телеметрией.  
OLTP заполняются данными при старте из файлов data.csv.  

Airflow DAG вычитывает данные с этих БД и сохраняет в OLAP БД. 
В качестве OLAP используется clickhouse. Изначально в clickhouse тоже есть немного данных, но они не содержат нужных логинов, которые есть в keycloak.  

Ежедневное расписание реализовано с помощью пресета @daily:
```
with DAG('bionic_pro_clickhouse_connect',
           default_args=default_args,
           schedule_interval='@daily', # По заданию - добавим расписание - ежедневно
           catchup=False) as dag:
```

## Задача 3. Создайте бэкенд-часть приложения для API.
Бэкенд реализован на питоне, используется FastAPI(backend:/container_name: bionicpro-report-service)
Endpoint /reports получает токен и проверяет его.  
По имени пользователя из токена происходит чтение из OLAP(clickhouse) таблицы и отдаёт её в фронт.  

## Задача 4. Реализуйте ограничение доступа к эндпоинту отчётности.
Ограничение реализовано в сервисе бэкенда.  
Результаты работы отображены в скринах.  

## Задача 5. Добавьте в UI кнопку получения отчёта и вызова эндпоинта его генерации.
Кнопка UI уже была в [Yandex-Practicum/architecture-bionicpro]<https://github.com/Yandex-Practicum/architecture-bionicpro/tree/PPROD-9631/frontend/src/components>.  
Нужно было настроить на отображение данных, отправляемых бэкендом.  





Скрины с данными:  

Попытка получить доступ неавторизованным пользователем:  
![back](images/backend1_unauthorized.png)
Логи с сервиса отчетов для неавторизованного и авторизованного доступа:  
![b2](images/backend2_unauthorized_and_authorized_log.png)
Результаты запусков ETL:  
![dag1](images/dag1.png)
Граф для графа:  
![dag2](images/dag2_graph.png)
Показано расписание выполнения - ежедневно в 00:00(daily):  
![dag3_schedule_daily.png](images/dag3_schedule_daily.png)
Данные с clickhouse, имитирующие OLAP:  
![OLAP_clickhouse_data.png](images/OLAP_clickhouse_data.png)
Результаты запросов для пользователя user1:  
![reports_user1.png](images/reports_user1.png)
Результаты запросов для пользователя user2:  
![reports_user2.png](images/reports_user2.png)
