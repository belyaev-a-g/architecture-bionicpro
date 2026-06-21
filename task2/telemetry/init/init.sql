-- 1. Создаем таблицу (убрали PRIMARY KEY, так как у одного девайса может быть много записей телеметрии)
CREATE TABLE IF NOT EXISTS telemetry (
    id_device UUID NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    model VARCHAR(255) NOT NULL,
    battery_level INT NOT NULL CHECK (battery_level >= 0 AND battery_level <= 100)
);

-- 2. Заполняем таблицу данными из CSV файла, который смонтирован внутрь контейнера
COPY telemetry(id_device, timestamp, model, battery_level)
FROM '/tmp/data.csv'
DELIMITER ','
CSV;

