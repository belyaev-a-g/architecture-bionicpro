CREATE DATABASE IF NOT EXISTS olap;

CREATE TABLE IF NOT EXISTS olap.customer_prostheses
(
    customer_id UInt32,
    keycloak_username String,
    full_name String,
    email String,
    country_code String,

    prosthesis_id UInt32,
    prosthesis_code String,
    model_name String,
    activated_at DateTime
)
ENGINE = MergeTree
ORDER BY (customer_id, prosthesis_id);

INSERT INTO olap.customer_prostheses VALUES
(
    1,
    'ivanov',
    'Ivan Ivanov',
    'ivanov@example.com',
    'RU',
    101,
    'PR-0001',
    'CyberLeg X1',
    '2025-01-10 10:00:00'
),
(
    2,
    'petrov',
    'Petr Petrov',
    'petrov@example.com',
    'RU',
    102,
    'PR-0002',
    'CyberArm A2',
    '2025-01-11 11:00:00'
),
(
    3,
    'smith',
    'John Smith',
    'smith@example.com',
    'US',
    103,
    'PR-0003',
    'NeuroHand Pro',
    '2025-01-12 12:00:00'
),
(
    4,
    'muller',
    'Hans Muller',
    'muller@example.com',
    'DE',
    104,
    'PR-0004',
    'BionicLeg V5',
    '2025-01-13 13:00:00'
),
(
    5,
    'sato',
    'Kenji Sato',
    'sato@example.com',
    'JP',
    105,
    'PR-0005',
    'FlexArm Z',
    '2025-01-14 14:00:00'
),
(
    6,
    'garcia',
    'Maria Garcia',
    'garcia@example.com',
    'ES',
    106,
    'PR-0006',
    'NeuroFoot Lite',
    '2025-01-15 15:00:00'
),
(
    7,
    'lee',
    'David Lee',
    'lee@example.com',
    'KR',
    107,
    'PR-0007',
    'SmartLeg S',
    '2025-01-16 16:00:00'
),
(
    8,
    'brown',
    'Charlie Brown',
    'brown@example.com',
    'UK',
    108,
    'PR-0008',
    'CyberKnee T',
    '2025-01-17 17:00:00'
),
(
    9,
    'ali',
    'Omar Ali',
    'ali@example.com',
    'AE',
    109,
    'PR-0009',
    'TitanArm M',
    '2025-01-18 18:00:00'
),
(
    10,
    'dupont',
    'Jean Dupont',
    'dupont@example.com',
    'FR',
    110,
    'PR-0010',
    'BionicGrip Q',
    '2025-01-19 19:00:00'
);
