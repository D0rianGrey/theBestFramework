FROM mcr.microsoft.com/playwright:v1.53.1-jammy

WORKDIR /app

# Копирование файлов проекта
COPY package.json package-lock.json ./
COPY playwright.config.ts ./
COPY tests/ ./tests/

# Установка зависимостей
RUN npm ci

# Команда для запуска тестов
CMD ["npx", "playwright", "test"]