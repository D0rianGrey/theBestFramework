#!/bin/bash

# Базовый скрипт для запуска тестов на Windows сервере
# Использует домашнюю директорию пользователя

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}

echo "🚀 Запуск тестов Playwright на Windows сервере (базовая версия)"
echo "Сервер: $REMOTE_HOST"
echo "Пользователь: $USERNAME"
echo "Base URL: $BASE_URL"
echo "----------------------------------------"

# Проверка соединения
echo "🔍 Проверка соединения..."
if ! ssh $USERNAME@$REMOTE_HOST "echo Соединение установлено"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST"
    exit 1
fi

echo "✅ Соединение установлено"

# Определяем домашнюю директорию пользователя
echo "📁 Определение домашней директории..."
HOME_DIR=$(ssh $USERNAME@$REMOTE_HOST "echo \$HOME" 2>/dev/null || ssh $USERNAME@$REMOTE_HOST "echo %USERPROFILE%" 2>/dev/null || echo ".")

if [ -z "$HOME_DIR" ] || [ "$HOME_DIR" = "." ]; then
    # Если не удалось определить, используем текущую директорию
    HOME_DIR="."
    echo "⚠️  Используем текущую директорию"
else
    echo "✅ Домашняя директория: $HOME_DIR"
fi

# Создание рабочей директории
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
WORK_DIR="playwright-tests-$TIMESTAMP"

echo "📁 Создание рабочей директории: $WORK_DIR"
ssh $USERNAME@$REMOTE_HOST "mkdir \"$WORK_DIR\" 2>/dev/null || md \"$WORK_DIR\" 2>/dev/null"

# Копирование файлов
echo "📤 Копирование файлов..."

# Основные файлы
for file in package.json package-lock.json playwright.config.ts Dockerfile .env; do
    if [ -f "$file" ]; then
        echo "Копирование $file..."
        scp "$file" "$USERNAME@$REMOTE_HOST:$WORK_DIR/" || echo "⚠️  Не удалось скопировать $file"
    fi
done

# Директория tests
if [ -d "tests" ]; then
    echo "Копирование директории tests..."
    scp -r tests "$USERNAME@$REMOTE_HOST:$WORK_DIR/" || echo "⚠️  Не удалось скопировать tests"
fi

# Создание директорий для отчетов
echo "📁 Создание директорий для отчетов..."
ssh $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && mkdir playwright-report test-results 2>/dev/null || (md playwright-report && md test-results) 2>/dev/null"

# Запуск тестов
echo "🧪 Запуск тестов..."

echo "Проверка содержимого рабочей директории..."
ssh $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && ls -la 2>/dev/null || dir"

echo "Сборка образа..."
if ssh $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && podman build -t playwright-tests ."; then
    echo "✅ Образ собран успешно"
    
    echo "Запуск контейнера..."
    # Получаем полный путь к рабочей директории
    FULL_WORK_DIR=$(ssh $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && pwd 2>/dev/null || cd")
    
    if ssh $USERNAME@$REMOTE_HOST "cd \"$WORK_DIR\" && podman run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \"\$(pwd)/playwright-report:/app/playwright-report\" -v \"\$(pwd)/test-results:/app/test-results\" playwright-tests"; then
        echo "✅ Тесты выполнены успешно!"
    else
        echo "❌ Тесты завершились с ошибками!"
    fi
else
    echo "❌ Ошибка при сборке образа!"
fi

# Копирование результатов
echo "📥 Копирование результатов..."
mkdir -p playwright-report test-results

echo "Копирование отчетов..."
scp -r "$USERNAME@$REMOTE_HOST:$WORK_DIR/playwright-report/*" ./playwright-report/ 2>/dev/null || echo "Нет файлов отчетов"
scp -r "$USERNAME@$REMOTE_HOST:$WORK_DIR/test-results/*" ./test-results/ 2>/dev/null || echo "Нет файлов результатов"

# Очистка
echo "🧹 Очистка..."
ssh $USERNAME@$REMOTE_HOST "rm -rf \"$WORK_DIR\" 2>/dev/null || rmdir /s /q \"$WORK_DIR\" 2>/dev/null" || echo "⚠️  Не удалось очистить рабочую директорию"

echo "🎉 Готово!"
echo "📊 Отчеты: playwright-report/"
echo "📋 Результаты: test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo "🌐 Просмотр отчета: open playwright-report/index.html"
fi
