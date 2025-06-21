#!/bin/bash

# Проверка и создание директорий для отчетов
if [ ! -d "playwright-report" ]; then
  echo "Создание директории playwright-report..."
  mkdir -p playwright-report
fi

if [ ! -d "test-results" ]; then
  echo "Создание директории test-results..."
  mkdir -p test-results
fi

# Сборка образа
podman build -t playwright-tests .

# Запуск контейнера с тестами
podman run --rm \
  -e BASE_URL_UI_TESTING=${BASE_URL_UI_TESTING:-https://example.com} \
  -e CONTAINER=true \
  -v "$(pwd)/playwright-report:/app/playwright-report" \
  -v "$(pwd)/test-results:/app/test-results" \
  playwright-tests