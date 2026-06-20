# Проверка заполняемости OLAP
docker compose up -d clickhouse
docker compose exec -it clickhouse clickhouse-client -u airflow --password airflow -d olap
SELECT * FROM customer_prostheses;


docker compose up -d telemetry_db
docker compose up -d crm_db

# Работа с данными CRM.
select c.full_name, p.device_id, p.model_name from prostheses p JOIN customers c ON p.customer_id = c.customer_id where c.login = 'john.doe';

