FROM python:3.12-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование всего проекта
COPY . .

# Открываем порт для Django
EXPOSE 8000

# Команда по умолчанию (для разработки)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]