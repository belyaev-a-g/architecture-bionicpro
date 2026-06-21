from __future__ import annotations

from fastapi import FastAPI, HTTPException, Query, Response, status, Security, Depends
import clickhouse_connect
import logging
import os

import jwt
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient

from typing import Any
from fastapi.middleware.cors import CORSMiddleware


security = HTTPBearer(auto_error=True)

# Настраиваем логирование
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="BionicPro Analytics API")

allowed_origins = [origin.strip() for origin in os.environ.get("ALLOWED_ORIGINS", "").split(",") if origin.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def print_clickhouse_config():
    print("--- Проверка конфигурации ClickHouse в окружении ---")
    print(f"KEYCLOAK_JWKS_URL: {os.environ.get('KEYCLOAK_JWKS_URL', 'НЕ ЗАДАН')}")
    print(f"CLICKHOUSE_HOST: {os.environ.get('CLICKHOUSE_HOST', 'НЕ ЗАДАН')}")
    print(f"CLICKHOUSE_PORT: {os.environ.get('CLICKHOUSE_PORT', 'НЕ ЗАДАН')}")
    print(f"CLICKHOUSE_USERNAME: {os.environ.get('CLICKHOUSE_USERNAME', 'default (значение по умолчанию)')}")
    print(f"CLICKHOUSE_DATABASE: {os.environ.get('CLICKHOUSE_DATABASE', 'default (значение по умолчанию)')}")
    print("---------------------------------------------------")

def get_current_claims(credentials: HTTPAuthorizationCredentials = Security(security)) -> dict:
    token = credentials.credentials
    jwks_client = PyJWKClient(os.environ["KEYCLOAK_JWKS_URL"])
    print("call get_current_claims")
    print(f"token {token}")
    print(f"jwks_client {jwks_client}")

    try:
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        return jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            issuer=os.environ["KEYCLOAK_EXPECTED_ISSUER"],
            options={"verify_aud": False},
        )
    except Exception as exc:
        print(f"get invalid token: {exc}")
        raise HTTPException(status_code=401, detail=f"Invalid token: {exc}") from exc

def get_clickhouse_client():
    print_clickhouse_config()
    return clickhouse_connect.get_client(
        host=os.environ["CLICKHOUSE_HOST"],
        port=int(os.environ["CLICKHOUSE_PORT"]),
        username=os.environ.get("CLICKHOUSE_USERNAME", "default"),
        password=os.environ.get("CLICKHOUSE_PASSWORD", ""),
        database=os.environ.get("CLICKHOUSE_DATABASE", "default"),
    )



# 1. НОВАЯ РУЧКА: Проверка работоспособности (Health Check)
@app.get("/health")
def health_check(response: Response):
    client = None
    try:
        client = get_clickhouse_client()
        # Выполняем максимально легкий запрос для проверки связи
        client.command("SELECT 1")
        return {"status": "healthy", "clickhouse": "connected"}
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "unhealthy", "reason": f"ClickHouse unavailable: {str(e)}"}
    finally:
        if client:
            client.close()

@app.get("/reports")
# Изменили аннотацию возвращаемого типа на list[dict[str, Any]] или просто list
def get_reports(claims: dict[str, Any] = Depends(get_current_claims)) -> list[dict[str, Any]]:
    login = claims.get("preferred_username")
    subject = claims.get("sub")

    print(f"login: {login}")
    print(f"subject: {subject}")

    client = None
    try:
        client = get_clickhouse_client()

        query = """
        SELECT
            login, first_name, last_name, e_mail, id_device, model,
            toString(timestamp) as timestamp, battery_level
        FROM olap.bionicpro_analytics FINAL
        WHERE login = {login_param:String}
        ORDER BY timestamp DESC
        """

        result = client.query(query, parameters={'login_param': login})

        if not result.result_rows:
            return []

        # Формируем JSON ответ, принудительно превращая UUID в str
        report_data = []
        for row in result.result_rows:
            row_dict = dict(zip(result.column_names, row))
            # ПРЕОБРАЗОВАНИЕ ТИПА: превращаем объект UUID в строку
            if "id_device" in row_dict:
                row_dict["id_device"] = str(row_dict["id_device"])
            report_data.append(row_dict)

        print(f"Safe result for JSON serialization: {report_data}")
        return report_data

    except Exception as e:
        logger.error(f"Error fetching report for login {login}: {str(e)}")
        print("It's my 500 ERROR")
        raise HTTPException(status_code=500, detail="Internal server error")

    finally:
        if client:
            client.close()
