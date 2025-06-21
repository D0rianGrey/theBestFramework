#!/bin/bash

# Создание директорий для отчетов, если они не существуют
mkdir -p playwright-report
mkdir -p test-results

# Сборка образа
podman build -t playwright-tests .

# Запуск контейнера с тестами
podman run --rm \
  -e BASE_URL_UI_TESTING=${BASE_URL_UI_TESTING:-https://example.com} \
  -e CONTAINER=true \
  -v "$(pwd)/playwright-report:/app/playwright-report" \
  -v "$(pwd)/test-results:/app/test-results" \
  playwright-tests
