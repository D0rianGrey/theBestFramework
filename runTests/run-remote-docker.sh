#!/bin/bash

# Настройки удаленного сервера
REMOTE_HOST=${REMOTE_HOST:-"yevhenii@192.168.195.211"}
# Путь к вашему ключу (по умолчанию стандартный путь)
SSH_KEY=${SSH_KEY:-"$HOME/.ssh/id_ed25519"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://example.com"}

# Проверка соединения с удаленным сервером
echo "Проверка соединения с $REMOTE_HOST..."
ssh -i $SSH_KEY $REMOTE_HOST "echo 'Соединение установлено'" || { echo "Ошибка соединения с $REMOTE_HOST"; exit 1; }

# Создание временной директории на удаленном сервере
REMOTE_TMP_DIR=$(ssh -i $SSH_KEY $REMOTE_HOST "mktemp -d")
echo "Создана временная директория: $REMOTE_TMP_DIR"

# Копирование файлов проекта на удаленный сервер
echo "Копирование файлов проекта на удаленный сервер..."
rsync -avz -e "ssh -i $SSH_KEY" \
  --exclude 'node_modules' \
  --exclude 'playwright-report' \
  --exclude 'test-results' \
  ./ $REMOTE_HOST:$REMOTE_TMP_DIR/

# Создание директорий для отчетов на удаленном сервере
echo "Создание директорий для отчетов на удаленном сервере..."
ssh -i $SSH_KEY $REMOTE_HOST "mkdir -p $REMOTE_TMP_DIR/playwright-report $REMOTE_TMP_DIR/test-results"

# Запуск Docker/Podman на удаленном сервере
echo "Запуск тестов на удаленном сервере..."
ssh -i $SSH_KEY $REMOTE_HOST "cd $REMOTE_TMP_DIR && \
  podman build -t playwright-tests . && \
  podman run --rm \
    -e BASE_URL_UI_TESTING=$BASE_URL \
    -e CONTAINER=true \
    -v $REMOTE_TMP_DIR/playwright-report:/app/playwright-report \
    -v $REMOTE_TMP_DIR/test-results:/app/test-results \
    playwright-tests"

# Копирование результатов тестов обратно
echo "Копирование результатов тестов обратно..."
mkdir -p playwright-report test-results
rsync -avz -e "ssh -i $SSH_KEY" \
  $REMOTE_HOST:$REMOTE_TMP_DIR/playwright-report/ ./playwright-report/
rsync -avz -e "ssh -i $SSH_KEY" \
  $REMOTE_HOST:$REMOTE_TMP_DIR/test-results/ ./test-results/

# Очистка временной директории
echo "Очистка временной директории на удаленном сервере..."
ssh -i $SSH_KEY $REMOTE_HOST "rm -rf $REMOTE_TMP_DIR"

echo "Тесты выполнены. Результаты доступны в директориях playwright-report и test-results."
