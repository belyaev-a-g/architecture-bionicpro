CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS prostheses_telemetry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    device_id UUID NOT NULL,

    event_time TIMESTAMP NOT NULL,

    model_name VARCHAR(255) NOT NULL,

    firmware_version VARCHAR(32) NOT NULL,

    active_minutes INTEGER NOT NULL,

    grip_actions INTEGER NOT NULL,

    avg_signal NUMERIC(10,4) NOT NULL,

    battery_level NUMERIC(10,4) NOT NULL,

    temperature NUMERIC(5,2) NOT NULL,

    error_code VARCHAR(32),

    CHECK (battery_level >= 0 AND battery_level <= 100),

    CHECK (temperature >= 20 AND temperature <= 100),

    CHECK (active_minutes >= 0),

    CHECK (grip_actions >= 0)
);

CREATE INDEX IF NOT EXISTS idx_prostheses_telemetry_time
ON prostheses_telemetry(event_time);

CREATE INDEX IF NOT EXISTS idx_prostheses_telemetry_device
ON prostheses_telemetry(device_id);

WITH prostheses AS (

    SELECT *
    FROM (
        VALUES
        (
            '11111111-1111-1111-1111-111111111111'::UUID,
            'CyberHand X1'
        ),
        (
            '22222222-2222-2222-2222-222222222222'::UUID,
            'NeuroGrip A2'
        ),
        (
            '33333333-3333-3333-3333-333333333333'::UUID,
            'BionicArm Pro'
        ),
        (
            '44444444-4444-4444-4444-444444444444'::UUID,
            'TitanGrip V5'
        ),
        (
            '55555555-5555-5555-5555-555555555555'::UUID,
            'CyberLeg S'
        ),
        (
            '66666666-6666-6666-6666-666666666666'::UUID,
            'NeuroFoot Lite'
        ),
        (
            '77777777-7777-7777-7777-777777777777'::UUID,
            'FlexArm Z'
        ),
        (
            '88888888-8888-8888-8888-888888888888'::UUID,
            'SmartKnee T'
        ),
        (
            '99999999-9999-9999-9999-999999999999'::UUID,
            'BioGrip Q'
        ),
        (
            'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID,
            'CyberHand X2'
        ),
        (
            'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID,
            'TitanArm M'
        ),
        (
            'cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID,
            'NeuroArm Ultra'
        ),
        (
            'dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID,
            'BionicGrip Lite'
        ),
        (
            'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::UUID,
            'FlexLeg R'
        ),
        (
            'ffffffff-ffff-ffff-ffff-ffffffffffff'::UUID,
            'SmartFoot X'
        )
    ) AS p(device_id, model_name)

)

INSERT INTO prostheses_telemetry
(
    device_id,
    event_time,
    model_name,
    firmware_version,
    active_minutes,
    grip_actions,
    avg_signal,
    battery_level,
    temperature,
    error_code
)
SELECT

    p.device_id,

    NOW() - ((100 - g) || ' hour')::INTERVAL,

    p.model_name,

    (
        ARRAY[
            '1.0.0',
            '1.1.0',
            '1.2.1',
            '2.0.0',
            '2.1.3'
        ]
    )[((g % 5) + 1)],

    60 + ((g * 11) % 240),

    CASE
        WHEN p.model_name ILIKE '%Leg%'
          OR p.model_name ILIKE '%Foot%'
          OR p.model_name ILIKE '%Knee%'
        THEN 0
        ELSE 100 + ((g * 17) % 500)
    END,

    ROUND((0.80 + ((g % 15) * 0.01))::numeric, 4),

    ROUND(GREATEST(5, (100 - (g * 0.65)))::numeric, 4),

    ROUND((36 + ((g % 10) * 1.4))::numeric, 2),

    CASE
        WHEN (g % 27) = 0 THEN 'BATTERY_LOW'
        WHEN (g % 41) = 0 THEN 'SIGNAL_LOSS'
        WHEN (g % 53) = 0 THEN 'MOTOR_OVERLOAD'
        WHEN (g % 67) = 0 THEN 'SENSOR_FAILURE'
        ELSE NULL
    END

FROM generate_series(1, 100) AS g

JOIN (
    SELECT
        ROW_NUMBER() OVER () AS rn,
        device_id,
        model_name
    FROM prostheses
) p
ON p.rn = ((g % 15) + 1);
