FROM python:3.11-slim

WORKDIR /app

# نصب curl برای healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# کپی فایل‌ها
COPY server.py .

# نصب dependencies
RUN pip install --no-cache-dir fastapi uvicorn telethon

# ساخت فولدر media
RUN mkdir -p media

EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "server.py"]