CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =========================================================
-- CUSTOMERS
-- =========================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    login VARCHAR(64) NOT NULL UNIQUE,

    email VARCHAR(255) NOT NULL UNIQUE,

    full_name VARCHAR(255) NOT NULL,

    country_code VARCHAR(8) NOT NULL,

    phone_number VARCHAR(32),

    customer_tier VARCHAR(32) NOT NULL,

    registered_at TIMESTAMP NOT NULL DEFAULT NOW(),

    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_customers_country
ON customers(country_code);

CREATE INDEX IF NOT EXISTS idx_customers_tier
ON customers(customer_tier);

-- =========================================================
-- PROSTHESES
-- =========================================================

CREATE TABLE IF NOT EXISTS prostheses (
    device_id UUID PRIMARY KEY,

    customer_id UUID NOT NULL REFERENCES customers(customer_id),

    model_name VARCHAR(255) NOT NULL,

    serial_number VARCHAR(128) NOT NULL UNIQUE,

    firmware_version VARCHAR(32) NOT NULL,

    status VARCHAR(32) NOT NULL,

    purchased_at TIMESTAMP NOT NULL,

    warranty_expires_at TIMESTAMP NOT NULL,

    last_service_at TIMESTAMP,

    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_prostheses_customer
ON prostheses(customer_id);

CREATE INDEX IF NOT EXISTS idx_prostheses_status
ON prostheses(status);

-- =========================================================
-- TEST DATA: CUSTOMERS
-- =========================================================

INSERT INTO customers
(
    customer_id,
    login,
    email,
    full_name,
    country_code,
    phone_number,
    customer_tier,
    registered_at,
    is_active
)
VALUES

(
    '10000000-0000-0000-0000-000000000001',
    'prothetic1',
    'ivanov@example.com',
    'Ivan Ivanov',
    'RU',
    '+79990000001',
    'PREMIUM',
    NOW() - INTERVAL '3 year',
    TRUE
),

(
    '10000000-0000-0000-0000-000000000002',
    'prothetic2',
    'petrov@example.com',
    'Petr Petrov',
    'RU',
    '+79990000002',
    'STANDARD',
    NOW() - INTERVAL '2 year',
    TRUE
),

(
    '10000000-0000-0000-0000-000000000003',
    'john.doe',
    'john.doe@example.com',
    'Joho Doe',
    'US',
    '+12025550101',
    'PREMIUM',
    NOW() - INTERVAL '5 year',
    TRUE
),

(
    '10000000-0000-0000-0000-000000000004',
    'muller',
    'muller@example.com',
    'Hans Muller',
    'DE',
    '+4915112345678',
    'STANDARD',
    NOW() - INTERVAL '1 year',
    TRUE
),

(
    '10000000-0000-0000-0000-000000000005',
    'sato',
    'sato@example.com',
    'Kenji Sato',
    'JP',
    '+81312345678',
    'VIP',
    NOW() - INTERVAL '4 year',
    TRUE
);

-- =========================================================
-- TEST DATA: PROSTHESES
-- =========================================================

INSERT INTO prostheses
(
    device_id,
    customer_id,
    model_name,
    serial_number,
    firmware_version,
    status,
    purchased_at,
    warranty_expires_at,
    last_service_at,
    is_active
)
VALUES

(
    '11111111-1111-1111-1111-111111111111',
    '10000000-0000-0000-0000-000000000001',
    'CyberHand X1',
    'SN-CHX1-0001',
    '2.1.3',
    'ACTIVE',
    NOW() - INTERVAL '2 year',
    NOW() + INTERVAL '1 year',
    NOW() - INTERVAL '3 month',
    TRUE
),

(
    '22222222-2222-2222-2222-222222222222',
    '10000000-0000-0000-0000-000000000001',
    'NeuroGrip A2',
    'SN-NGA2-0001',
    '2.0.0',
    'ACTIVE',
    NOW() - INTERVAL '1 year',
    NOW() + INTERVAL '2 year',
    NOW() - INTERVAL '1 month',
    TRUE
),

(
    '33333333-3333-3333-3333-333333333333',
    '10000000-0000-0000-0000-000000000002',
    'BionicArm Pro',
    'SN-BAP-0001',
    '1.2.1',
    'SERVICE',
    NOW() - INTERVAL '3 year',
    NOW() - INTERVAL '1 month',
    NOW() - INTERVAL '10 day',
    TRUE
),

(
    '44444444-4444-4444-4444-444444444444',
    '10000000-0000-0000-0000-000000000003',
    'TitanGrip V5',
    'SN-TGV5-0001',
    '1.1.0',
    'ACTIVE',
    NOW() - INTERVAL '8 month',
    NOW() + INTERVAL '28 month',
    NOW() - INTERVAL '20 day',
    TRUE
),

(
    '55555555-5555-5555-5555-555555555555',
    '10000000-0000-0000-0000-000000000003',
    'CyberLeg S',
    'SN-CLS-0001',
    '2.1.3',
    'ACTIVE',
    NOW() - INTERVAL '2 year',
    NOW() + INTERVAL '6 month',
    NOW() - INTERVAL '2 month',
    TRUE
),

(
    '66666666-6666-6666-6666-666666666666',
    '10000000-0000-0000-0000-000000000004',
    'NeuroFoot Lite',
    'SN-NFL-0001',
    '1.0.0',
    'REPAIR',
    NOW() - INTERVAL '4 year',
    NOW() - INTERVAL '1 year',
    NOW() - INTERVAL '5 day',
    FALSE
),

(
    '77777777-7777-7777-7777-777777777777',
    '10000000-0000-0000-0000-000000000005',
    'FlexArm Z',
    'SN-FAZ-0001',
    '2.0.0',
    'ACTIVE',
    NOW() - INTERVAL '6 month',
    NOW() + INTERVAL '30 month',
    NOW() - INTERVAL '15 day',
    TRUE
),

(
    '88888888-8888-8888-8888-888888888888',
    '10000000-0000-0000-0000-000000000005',
    'SmartKnee T',
    'SN-SKT-0001',
    '2.1.3',
    'INACTIVE',
    NOW() - INTERVAL '5 year',
    NOW() - INTERVAL '2 year',
    NOW() - INTERVAL '6 month',
    FALSE
);
