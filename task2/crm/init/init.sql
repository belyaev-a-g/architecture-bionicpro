-- 2. Создаем измененную таблицу clients
CREATE TABLE IF NOT EXISTS clients (
    login VARCHAR(50) PRIMARY KEY,
    id_device UUID NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL, -- Добавлено: Имя
    last_name VARCHAR(100) NOT NULL,  -- Добавлено: Фамилия
    e_mail VARCHAR(255) NOT NULL UNIQUE,
    contract_date DATE NOT NULL DEFAULT CURRENT_DATE
);


-- 4. Заполняем таблицу clients данными (с учетом новых колонок)
COPY clients(login, id_device, first_name, last_name, e_mail, contract_date)
FROM '/tmp/data.csv'
DELIMITER ','
CSV;

