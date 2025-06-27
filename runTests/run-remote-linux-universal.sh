#!/bin/bash

# Универсальный скрипт для запуска тестов на Linux/WSL сервере
# Работает с обычным Linux сервером или WSL как с Linux

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"yevhenii@192.168.195.211"}
SSH_KEY=${SSH_KEY:-"$HOME/.ssh/id_ed25519"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}
CONTAINER_ENGINE=${CONTAINER_ENGINE:-"docker"}  # docker или podman

echo "🚀 Запуск тестов на Linux/WSL сервере"
echo "Сервер: $REMOTE_HOST"
echo "SSH ключ: $SSH_KEY"
echo "Base URL: $BASE_URL"
echo "Контейнер: $CONTAINER_ENGINE"
echo "----------------------------------------"

# Проверка соединения с удаленным сервером
echo "🔍 Проверка соединения с $REMOTE_HOST..."
if ! ssh -i $SSH_KEY $REMOTE_HOST "echo 'Соединение установлено'"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST"
    echo ""
    echo "💡 Проверьте:"
    echo "   1. SSH ключ: $SSH_KEY"
    echo "   2. Доступность сервера: $REMOTE_HOST"
    echo "   3. SSH сервер запущен на удаленной машине"
    exit 1
fi

echo "✅ Соединение установлено"

# Проверка контейнерного движка
echo "🐳 Проверка $CONTAINER_ENGINE на удаленном сервере..."
if ! ssh -i $SSH_KEY $REMOTE_HOST "$CONTAINER_ENGINE --version"; then
    echo "❌ $CONTAINER_ENGINE не найден на удаленном сервере"
    echo ""
    echo "🔧 Для установки Docker:"
    echo "   sudo apt update"
    echo "   sudo apt install docker.io"
    echo "   sudo systemctl start docker"
    echo "   sudo usermod -aG docker \$USER"
    echo ""
    echo "🔧 Для установки Podman:"
    echo "   sudo apt update"
    echo "   sudo apt install podman"
    exit 1
fi

echo "✅ $CONTAINER_ENGINE найден на удаленном сервере"

# Проверка, что контейнерный движок работает
echo "Проверка работы $CONTAINER_ENGINE..."
if ! ssh -i $SSH_KEY $REMOTE_HOST "$CONTAINER_ENGINE ps >/dev/null 2>&1"; then
    echo "⚠️  $CONTAINER_ENGINE не работает, пытаемся запустить..."
    
    if [ "$CONTAINER_ENGINE" = "docker" ]; then
        ssh -i $SSH_KEY $REMOTE_HOST "sudo service docker start" || echo "Не удалось запустить Docker"
    fi
    
    # Повторная проверка
    if ! ssh -i $SSH_KEY $REMOTE_HOST "$CONTAINER_ENGINE ps >/dev/null 2>&1"; then
        echo "❌ $CONTAINER_ENGINE не работает"
        echo "Попробуйте вручную запустить на сервере"
        exit 1
    fi
fi

echo "✅ $CONTAINER_ENGINE работает"

# Создание временной директории на удаленном сервере
echo "📁 Создание временной директории..."
REMOTE_TMP_DIR=$(ssh -i $SSH_KEY $REMOTE_HOST "mktemp -d")
echo "Создана временная директория: $REMOTE_TMP_DIR"

# Копирование файлов проекта на удаленный сервер
echo "📤 Копирование файлов проекта на удаленный сервер..."
rsync -avz -e "ssh -i $SSH_KEY" \
  --exclude 'node_modules' \
  --exclude 'playwright-report' \
  --exclude 'test-results' \
  --exclude '.git' \
  ./ $REMOTE_HOST:$REMOTE_TMP_DIR/

# Создание директорий для отчетов на удаленном сервере
echo "📁 Создание директорий для отчетов..."
ssh -i $SSH_KEY $REMOTE_HOST "mkdir -p $REMOTE_TMP_DIR/playwright-report $REMOTE_TMP_DIR/test-results"

# Запуск контейнера на удаленном сервере
echo "🧪 Запуск тестов на удаленном сервере..."
ssh -i $SSH_KEY $REMOTE_HOST "cd $REMOTE_TMP_DIR && \
  $CONTAINER_ENGINE build -t playwright-tests . && \
  $CONTAINER_ENGINE run --rm \
    -e BASE_URL_UI_TESTING=$BASE_URL \
    -e CONTAINER=true \
    -v $REMOTE_TMP_DIR/playwright-report:/app/playwright-report \
    -v $REMOTE_TMP_DIR/test-results:/app/test-results \
    playwright-tests"

# Проверка результата
if [ $? -eq 0 ]; then
    echo "✅ Тесты выполнены успешно!"
else
    echo "❌ Тесты завершились с ошибками!"
fi

# Копирование результатов тестов обратно
echo "📥 Копирование результатов тестов обратно..."
mkdir -p playwright-report test-results

rsync -avz -e "ssh -i $SSH_KEY" \
  $REMOTE_HOST:$REMOTE_TMP_DIR/playwright-report/ ./playwright-report/

rsync -avz -e "ssh -i $SSH_KEY" \
  $REMOTE_HOST:$REMOTE_TMP_DIR/test-results/ ./test-results/

# Очистка временной директории
echo "🧹 Очистка временной директории на удаленном сервере..."
ssh -i $SSH_KEY $REMOTE_HOST "rm -rf $REMOTE_TMP_DIR"

echo "🎉 Тесты выполнены!"
echo "📊 Результаты доступны в директориях:"
echo "   playwright-report/"
echo "   test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo ""
    echo "🌐 Для просмотра отчета выполните:"
    echo "   open playwright-report/index.html"
fi

echo ""
echo "ℹ️  Этот скрипт работает с:"
echo "   ✅ Обычными Linux серверами"
echo "   ✅ WSL как Linux сервером"
echo "   ✅ Docker и Podman"
