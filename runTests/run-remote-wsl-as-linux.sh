#!/bin/bash

# Простой скрипт для запуска тестов на WSL как на обычном Linux сервере
# Подключается напрямую к WSL через SSH, минуя Windows

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}
SSH_PORT=${SSH_PORT:-"22"}

echo "🚀 Запуск тестов на WSL (как Linux сервер)"
echo "Сервер: $REMOTE_HOST:$SSH_PORT"
echo "Пользователь: $USERNAME"
echo "Base URL: $BASE_URL"
echo "----------------------------------------"

# Проверка соединения
echo "🔍 Проверка соединения с WSL..."
if ! ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "echo 'Соединение с WSL установлено'"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST:$SSH_PORT"
    echo ""
    echo "💡 Убедитесь что:"
    echo "   1. SSH сервер запущен в WSL (не в Windows)"
    echo "   2. Порт $SSH_PORT открыт и перенаправлен на WSL"
    echo "   3. Правильные учетные данные для WSL"
    echo ""
    echo "🔧 Для настройки SSH в WSL:"
    echo "   sudo apt update"
    echo "   sudo apt install openssh-server"
    echo "   sudo service ssh start"
    echo "   sudo systemctl enable ssh"
    exit 1
fi

echo "✅ Соединение с WSL установлено"

# Проверка Docker
echo "🐳 Проверка Docker в WSL..."
if ! ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "docker --version"; then
    echo "❌ Docker не найден в WSL"
    echo ""
    echo "🔧 Для установки Docker в WSL:"
    echo "   sudo apt update"
    echo "   sudo apt install docker.io"
    echo "   sudo systemctl start docker"
    echo "   sudo systemctl enable docker"
    echo "   sudo usermod -aG docker \$USER"
    exit 1
fi

echo "✅ Docker найден в WSL"

# Проверка Docker daemon
echo "Проверка Docker daemon..."
if ! ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "docker ps >/dev/null 2>&1"; then
    echo "⚠️  Docker daemon не запущен, пытаемся запустить..."
    ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "sudo service docker start" || echo "Не удалось запустить Docker"
    
    # Повторная проверка
    if ! ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "docker ps >/dev/null 2>&1"; then
        echo "❌ Docker daemon не работает"
        echo "Попробуйте вручную: sudo service docker start"
        exit 1
    fi
fi

echo "✅ Docker daemon работает"

# Создание рабочей директории
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
WORK_DIR="playwright-tests-$TIMESTAMP"

echo "📁 Создание рабочей директории: $WORK_DIR"
ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "mkdir -p \"$WORK_DIR\""

# Копирование файлов (как на обычный Linux сервер)
echo "📤 Копирование файлов..."

# Основные файлы
for file in package.json package-lock.json playwright.config.ts Dockerfile .env; do
    if [ -f "$file" ]; then
        echo "Копирование $file..."
        scp -P $SSH_PORT "$file" "$USERNAME@$REMOTE_HOST:$WORK_DIR/" || echo "⚠️  Не удалось скопировать $file"
    fi
done

# Директория tests
if [ -d "tests" ]; then
    echo "Копирование директории tests..."
    scp -P $SSH_PORT -r tests "$USERNAME@$REMOTE_HOST:$WORK_DIR/" || echo "⚠️  Не удалось скопировать tests"
fi

# Создание директорий для отчетов
echo "📁 Создание директорий для отчетов..."
ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && mkdir -p playwright-report test-results"

# Запуск тестов (как на обычном Linux)
echo "🧪 Запуск тестов в Docker..."

echo "Проверка содержимого рабочей директории..."
ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && ls -la"

echo "Сборка Docker образа..."
if ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && docker build -t playwright-tests ."; then
    echo "✅ Docker образ собран успешно"
    
    echo "Запуск контейнера..."
    if ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && docker run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \"\$(pwd)/playwright-report:/app/playwright-report\" -v \"\$(pwd)/test-results:/app/test-results\" playwright-tests"; then
        echo "✅ Тесты выполнены успешно!"
    else
        echo "❌ Тесты завершились с ошибками!"
    fi
else
    echo "❌ Ошибка при сборке Docker образа!"
fi

# Копирование результатов (как с обычного Linux сервера)
echo "📥 Копирование результатов..."
mkdir -p playwright-report test-results

echo "Копирование отчетов..."
scp -P $SSH_PORT -r "$USERNAME@$REMOTE_HOST:$WORK_DIR/playwright-report/*" ./playwright-report/ 2>/dev/null || echo "Нет файлов отчетов"
scp -P $SSH_PORT -r "$USERNAME@$REMOTE_HOST:$WORK_DIR/test-results/*" ./test-results/ 2>/dev/null || echo "Нет файлов результатов"

# Очистка
echo "🧹 Очистка..."
ssh -p $SSH_PORT $USERNAME@$REMOTE_HOST "rm -rf \"$WORK_DIR\"" || echo "⚠️  Не удалось очистить рабочую директорию"

echo "🎉 Готово!"
echo "📊 Отчеты: playwright-report/"
echo "📋 Результаты: test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo "🌐 Просмотр отчета: open playwright-report/index.html"
fi

echo ""
echo "ℹ️  Процесс выполнения:"
echo "   Mac/Linux → SSH → WSL (как Linux) → Docker → Playwright"
echo ""
echo "💡 Этот скрипт работает с WSL как с обычным Linux сервером"
echo "   Никаких специальных команд Windows не используется"
