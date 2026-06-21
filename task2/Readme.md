
# Задание 2. Разработка сервиса отчётов
## Задача 1. Создать архитектуру решения для подготовки и получения отчётов.


![Внедрение ETL](BionicPRO_task2.png)


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
