FROM python:3.10-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем и устанавливаем только необходимые для API зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY ./app ./app

# Открываем порт для FastAPI
EXPOSE 8000

# Запускаем приложение
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

