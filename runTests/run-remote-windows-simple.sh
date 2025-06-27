#!/bin/bash

# Простой скрипт для запуска тестов на Windows сервере с Mac
# Использует только базовые Windows команды

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}

echo "🚀 Запуск тестов Playwright на Windows сервере (простая версия)"
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

# Создание простой временной директории
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REMOTE_TEMP_DIR="C:/temp/playwright-tests-$TIMESTAMP"

echo "📁 Создание временной директории: $REMOTE_TEMP_DIR"
# Создаем директорию через SSH, используя обычные команды
ssh $USERNAME@$REMOTE_HOST "mkdir -p \"$REMOTE_TEMP_DIR\" 2>/dev/null || mkdir \"$REMOTE_TEMP_DIR\" 2>/dev/null || md \"$REMOTE_TEMP_DIR\" 2>/dev/null"

# Копирование файлов
echo "📤 Копирование файлов..."

# Основные файлы
for file in package.json package-lock.json playwright.config.ts Dockerfile .env; do
    if [ -f "$file" ]; then
        echo "Копирование $file..."
        scp "$file" "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/" || echo "⚠️  Не удалось скопировать $file"
    fi
done

# Директория tests
if [ -d "tests" ]; then
    echo "Копирование директории tests..."
    scp -r tests "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/" || echo "⚠️  Не удалось скопировать tests"
fi

# Создание директорий для отчетов
echo "📁 Создание директорий для отчетов..."
ssh $USERNAME@$REMOTE_HOST "mkdir -p \"$REMOTE_TEMP_DIR/playwright-report\" \"$REMOTE_TEMP_DIR/test-results\" 2>/dev/null || (mkdir \"$REMOTE_TEMP_DIR/playwright-report\" && mkdir \"$REMOTE_TEMP_DIR/test-results\") 2>/dev/null"

# Запуск тестов
echo "🧪 Запуск тестов..."

echo "Переход в рабочую директорию: $REMOTE_TEMP_DIR"
ssh $USERNAME@$REMOTE_HOST "cd \"$REMOTE_TEMP_DIR\" && pwd"

echo "Сборка образа..."
if ssh $USERNAME@$REMOTE_HOST "cd \"$REMOTE_TEMP_DIR\" && podman build -t playwright-tests ."; then
    echo "✅ Образ собран успешно"

    echo "Запуск контейнера..."
    # Используем обычные пути для volume mapping
    if ssh $USERNAME@$REMOTE_HOST "cd \"$REMOTE_TEMP_DIR\" && podman run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \"$REMOTE_TEMP_DIR/playwright-report:/app/playwright-report\" -v \"$REMOTE_TEMP_DIR/test-results:/app/test-results\" playwright-tests"; then
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
scp -r "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/playwright-report/*" ./playwright-report/ 2>/dev/null || echo "Нет файлов отчетов"
scp -r "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/test-results/*" ./test-results/ 2>/dev/null || echo "Нет файлов результатов"

# Очистка
echo "🧹 Очистка..."
ssh $USERNAME@$REMOTE_HOST "rm -rf \"$REMOTE_TEMP_DIR\"" || echo "⚠️  Не удалось очистить временную директорию"

echo "🎉 Готово!"
echo "📊 Отчеты: playwright-report/"
echo "📋 Результаты: test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo "🌐 Просмотр отчета: open playwright-report/index.html"
fi
