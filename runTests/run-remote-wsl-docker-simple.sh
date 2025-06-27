#!/bin/bash

# Упрощенный скрипт для запуска тестов в Docker на WSL
# Использует прямое копирование в WSL без промежуточного Windows

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}
WSL_DISTRO=${WSL_DISTRO:-"Ubuntu"}

echo "🚀 Запуск тестов в Docker на WSL (упрощенная версия)"
echo "Сервер: $REMOTE_HOST"
echo "Пользователь: $USERNAME"
echo "WSL: $WSL_DISTRO"
echo "Base URL: $BASE_URL"
echo "----------------------------------------"

# Проверка соединения
echo "🔍 Проверка соединения..."
if ! ssh $USERNAME@$REMOTE_HOST "echo Соединение установлено"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST"
    exit 1
fi

# Проверка WSL и Docker
echo "🐧 Проверка WSL и Docker..."

# Сначала проверим, что WSL это действительно Windows Subsystem for Linux
echo "Проверка типа WSL..."
WSL_CHECK=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe --version 2>/dev/null || echo 'NOT_FOUND'")

if [[ "$WSL_CHECK" == *"NOT_FOUND"* ]] || [[ "$WSL_CHECK" == *"Wsman"* ]]; then
    echo "❌ Windows Subsystem for Linux не найден"
    echo "На сервере найдена другая утилита 'wsl' (возможно Wsman Shell)"
    echo ""
    echo "Для использования этого скрипта необходимо:"
    echo "  1. Установить Windows Subsystem for Linux (WSL)"
    echo "  2. Установить Linux дистрибутив (например Ubuntu)"
    echo "  3. Установить Docker в WSL дистрибутиве"
    echo ""
    echo "Команды для установки WSL на Windows сервере:"
    echo "  wsl --install"
    echo "  wsl --install -d Ubuntu"
    exit 1
fi

echo "✅ Windows Subsystem for Linux найден"

# Проверка конкретного дистрибутива и Docker
echo "Проверка дистрибутива $WSL_DISTRO и Docker..."
if ! ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- docker --version"; then
    echo "❌ Дистрибутив $WSL_DISTRO или Docker не доступны"
    echo "Убедитесь что:"
    echo "  1. Дистрибутив $WSL_DISTRO установлен в WSL"
    echo "  2. Docker установлен в дистрибутиве $WSL_DISTRO"
    echo "  3. Docker daemon запущен"
    echo ""
    echo "Проверить доступные дистрибутивы: wsl.exe -l -v"
    exit 1
fi

echo "✅ WSL и Docker готовы к работе"

# Создание рабочей директории
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
WORK_DIR="playwright-tests-$TIMESTAMP"

echo "📁 Создание рабочей директории в WSL..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- mkdir -p \"/tmp/$WORK_DIR\""

# Создание временного архива проекта
echo "📦 Создание архива проекта..."
TEMP_ARCHIVE="/tmp/playwright-project-$TIMESTAMP.tar.gz"

# Создаем архив локально
tar -czf "$TEMP_ARCHIVE" \
    --exclude='node_modules' \
    --exclude='playwright-report' \
    --exclude='test-results' \
    --exclude='.git' \
    package.json package-lock.json playwright.config.ts Dockerfile .env tests/ 2>/dev/null

if [ ! -f "$TEMP_ARCHIVE" ]; then
    echo "❌ Не удалось создать архив проекта"
    exit 1
fi

# Копирование архива на Windows сервер
echo "📤 Копирование архива на сервер..."
scp "$TEMP_ARCHIVE" "$USERNAME@$REMOTE_HOST:project.tar.gz"

# Извлечение архива в WSL
echo "📋 Извлечение архива в WSL..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd /tmp/$WORK_DIR && tar -xzf ~/project.tar.gz'"

# Создание директорий для отчетов
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- mkdir -p \"/tmp/$WORK_DIR/playwright-report\" \"/tmp/$WORK_DIR/test-results\""

# Запуск тестов
echo "🧪 Запуск тестов в Docker..."

echo "Сборка образа..."
if ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd /tmp/$WORK_DIR && docker build -t playwright-tests .'"; then
    echo "✅ Образ собран успешно"

    echo "Запуск контейнера..."
    if ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd /tmp/$WORK_DIR && docker run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \$(pwd)/playwright-report:/app/playwright-report -v \$(pwd)/test-results:/app/test-results playwright-tests'"; then
        echo "✅ Тесты выполнены успешно!"
    else
        echo "❌ Тесты завершились с ошибками!"
    fi
else
    echo "❌ Ошибка при сборке образа!"
fi

# Создание архива результатов в WSL
echo "📥 Подготовка результатов..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd /tmp/$WORK_DIR && tar -czf ~/results.tar.gz playwright-report/ test-results/ 2>/dev/null || echo \"Нет результатов для архивации\"'"

# Копирование результатов
echo "Копирование результатов..."
mkdir -p playwright-report test-results

# Копируем архив результатов
scp "$USERNAME@$REMOTE_HOST:results.tar.gz" "/tmp/results-$TIMESTAMP.tar.gz" 2>/dev/null

# Извлекаем результаты локально
if [ -f "/tmp/results-$TIMESTAMP.tar.gz" ]; then
    tar -xzf "/tmp/results-$TIMESTAMP.tar.gz" 2>/dev/null || echo "Нет результатов для извлечения"
    rm "/tmp/results-$TIMESTAMP.tar.gz"
else
    echo "Нет файлов результатов"
fi

# Очистка
echo "🧹 Очистка..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- rm -rf \"/tmp/$WORK_DIR\"" 2>/dev/null
ssh $USERNAME@$REMOTE_HOST "rm -f project.tar.gz results.tar.gz" 2>/dev/null
rm -f "$TEMP_ARCHIVE" 2>/dev/null

echo "🎉 Готово!"
echo "📊 Отчеты: playwright-report/"
echo "📋 Результаты: test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo "🌐 Просмотр отчета: open playwright-report/index.html"
fi

echo ""
echo "ℹ️  Процесс выполнения:"
echo "   Mac/Linux → SSH → Windows → WSL → Docker → Playwright"
