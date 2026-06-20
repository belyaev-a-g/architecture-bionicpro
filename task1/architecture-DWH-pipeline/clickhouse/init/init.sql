CREATE DATABASE IF NOT EXISTS olap;

CREATE TABLE IF NOT EXISTS olap.bionicpro_analytics (
    login String,
    first_name String,
    last_name String,
    e_mail String,
    id_device UUID,
    model String,
    timestamp DateTime64(3, 'Europe/Moscow'),
    battery_level UInt8
)
ENGINE = ReplacingMergeTree()
PRIMARY KEY (login, timestamp)
ORDER BY (login, timestamp, id_device);

-- Импортируем данные из CSV-файла, сохраненного внутри контейнера
INSERT INTO olap.bionicpro_analytics 
FROM INFILE '/tmp/data.csv' 
FORMAT CSV;
