CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    keycloak_username VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    country_code VARCHAR(10) NOT NULL
);

CREATE TABLE prostheses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    prosthesis_code VARCHAR(64) NOT NULL UNIQUE,
    model_name VARCHAR(255) NOT NULL,
    activated_at TIMESTAMP NOT NULL
);


INSERT INTO customers (id, keycloak_username, full_name, email, country_code) VALUES
    (1, 'prothetic1', 'Stepan Stepanov', 'prothetic1@example.com', 'RU'),
    (2, 'prothetic2', 'Ivan Ivanov', 'prothetic2@example.com', 'RU'),
    (3, 'prothetic3', 'Semen Semenov', 'prothetic3@example.com', 'KZ'),
    (4, 'prothetic4', 'Petr Petrov', 'prothetic4@example.com', 'KZ'),
    (5, 'prothetic5', 'Kirill Sidorov', 'prothetic5@example.com', 'KZ'),
    (6, 'john.doe', 'John Doe', 'john.doe@example.com', 'USA');


INSERT INTO prostheses (customer_id, prosthesis_code, model_name, activated_at) VALUES
    (1, '101', 'BionicPRO Arm X', NOW() - INTERVAL '180 days'),
    (2, '102', 'BionicPRO Arm X', NOW() - INTERVAL '120 days'),
    (3, '103', 'BionicPRO Arm Lite', NOW() - INTERVAL '90 days'),
    (4, '104', 'BionicPRO Arm Lite', NOW() - INTERVAL '90 days'),
    (5, '105', 'BionicPRO Arm Lite', NOW() - INTERVAL '90 days'),
    (6, '106', 'BionicPRO Arm Lite', NOW() - INTERVAL '90 days');
