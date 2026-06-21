from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime
import pandas as pd
import clickhouse_connect  # Официальный клиент ClickHouse

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 12, 1),
}

# Шаг 1: Скачиваем телеметрию и сохраняем в XCom в формате JSON
def extract_telemetry(**kwargs):
    pg_hook = PostgresHook(postgres_conn_id='write_to_postgres_telemetry')
    df = pg_hook.get_pandas_df(sql="SELECT id_device, timestamp, model, battery_level FROM telemetry;")
    return df.to_json(orient='records', date_format='iso')

# Шаг 2: Скачиваем CRM-клиентов и сохраняем в XCom в формате JSON
def extract_crm_clients(**kwargs):
    pg_hook = PostgresHook(postgres_conn_id='write_to_postgres_crm')
    df = pg_hook.get_pandas_df(sql="SELECT login, first_name, last_name, e_mail, id_device FROM clients;")
    return df.to_json(orient='records', date_format='iso')

# Шаг 3: Забираем данные из XCom, объединяем и пишем в ClickHouse через clickhouse-connect
def merge_and_load_to_clickhouse(**kwargs):
    ti = kwargs['ti']
    telemetry_json = ti.xcom_pull(task_ids='get_telemetry_data')
    clients_json = ti.xcom_pull(task_ids='get_crm_clients_data')
    
    if not telemetry_json or not clients_json:
        print("Данные из одного из источников не получены.")
        return

    # Восстанавливаем таблицы из JSON-строк
    telemetry_df = pd.read_json(telemetry_json)
    clients_df = pd.read_json(clients_json)
    
    if telemetry_df.empty or clients_df.empty:
        print("Один из датафреймов пуст.")
        return

    # Объединяем данные по полю id_device (аналог SQL INNER JOIN)
    merged_df = pd.merge(clients_df, telemetry_df, on='id_device', how='inner')
    
    # clickhouse-connect идеально работает с типами pandas, 
    # но UUID лучше передать как строки, чтобы избежать конфликтов типов
    merged_df['id_device'] = merged_df['id_device'].astype(str)
    merged_df['timestamp'] = pd.to_datetime(merged_df['timestamp'])

    # Инициализируем прямое подключение к ClickHouse (используется HTTP-порт 8123)
    client = clickhouse_connect.get_client(
        host='clickhouse',             # Имя сервиса/контейнера из вашего docker-compose
        port=8123,                     # HTTP порт ClickHouse
        username='airflow',            # Пользователь по умолчанию
        password='airflow'             # Если пароль не задан, оставляем пустую строку
    )

    # Записываем Pandas DataFrame напрямую в таблицу одной командой!
    # Библиотека сама сопоставит имена колонок DataFrame с колонками таблицы.
    client.insert_df(
        table='bionicpro_analytics',
        df=merged_df,
        database='olap'
    )
    
    print(f"Успешно объединено и записано в ClickHouse {len(merged_df)} строк.")
    
    # Закрываем сессию подключения
    client.close()


with DAG('bionic_pro_clickhouse_connect',
         default_args=default_args,
         schedule_interval='@daily', # По заданию - добавим расписание - ежедневно
         catchup=False) as dag:

    get_telemetry = PythonOperator(
        task_id='get_telemetry_data',
        python_callable=extract_telemetry
    )

    get_crm_clients = PythonOperator(
        task_id='get_crm_clients_data',
        python_callable=extract_crm_clients
    )

    load_to_clickhouse = PythonOperator(
        task_id='merge_and_load_to_ch',
        python_callable=merge_and_load_to_clickhouse
    )

    # Визуальная структура графа
    [get_telemetry, get_crm_clients] >> load_to_clickhouse
