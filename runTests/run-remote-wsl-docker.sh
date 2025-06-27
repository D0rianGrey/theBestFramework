#!/bin/bash

# Скрипт для запуска тестов в Docker на Linux (WSL) внутри Windows сервера
# Mac/Linux → SSH → Windows → WSL → Docker → Playwright Tests

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://the-internet.herokuapp.com"}
WSL_DISTRO=${WSL_DISTRO:-"Ubuntu"}  # Название WSL дистрибутива

echo "🚀 Запуск тестов Playwright в Docker на WSL (Windows сервер)"
echo "Сервер: $REMOTE_HOST"
echo "Пользователь: $USERNAME"
echo "WSL дистрибутив: $WSL_DISTRO"
echo "Base URL: $BASE_URL"
echo "----------------------------------------"

# Проверка соединения с Windows сервером
echo "🔍 Проверка соединения с Windows сервером..."
if ! ssh $USERNAME@$REMOTE_HOST "echo Соединение с Windows установлено"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST"
    exit 1
fi

echo "✅ Соединение с Windows сервером установлено"

# Проверка WSL на удаленном сервере
echo "🐧 Проверка WSL на удаленном сервере..."

# Проверяем, что это действительно Windows Subsystem for Linux
WSL_CHECK=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe --version 2>/dev/null || echo 'NOT_FOUND'")

if [[ "$WSL_CHECK" == *"NOT_FOUND"* ]] || [[ "$WSL_CHECK" == *"Wsman"* ]]; then
    echo "❌ Windows Subsystem for Linux не найден"
    echo "На сервере найдена другая утилита 'wsl' (возможно Wsman Shell)"
    echo "Убедитесь что Windows Subsystem for Linux установлен"
    exit 1
fi

if ! ssh $USERNAME@$REMOTE_HOST "wsl.exe -l -v"; then
    echo "❌ WSL не настроен или нет доступных дистрибутивов"
    echo "Убедитесь что WSL установлен и настроен"
    exit 1
fi

echo "✅ WSL найден на удаленном сервере"

# Проверка Docker в WSL
echo "🐳 Проверка Docker в WSL..."
if ! ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- docker --version"; then
    echo "❌ Docker не найден в WSL дистрибутиве $WSL_DISTRO"
    echo "Убедитесь что Docker установлен в WSL"
    exit 1
fi

echo "✅ Docker найден в WSL"

# Создание рабочей директории в WSL
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
WSL_WORK_DIR="/tmp/playwright-tests-$TIMESTAMP"

echo "📁 Создание рабочей директории в WSL: $WSL_WORK_DIR"
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- mkdir -p \"$WSL_WORK_DIR\""

# Копирование файлов на Windows, затем в WSL
echo "📤 Копирование файлов..."

# Создаем временную директорию на Windows
WIN_TEMP_DIR="playwright-temp-$TIMESTAMP"
ssh $USERNAME@$REMOTE_HOST "mkdir \"$WIN_TEMP_DIR\""

# Копируем файлы на Windows
echo "Копирование файлов на Windows сервер..."
for file in package.json package-lock.json playwright.config.ts Dockerfile .env; do
    if [ -f "$file" ]; then
        echo "Копирование $file..."
        scp "$file" "$USERNAME@$REMOTE_HOST:$WIN_TEMP_DIR/" || echo "⚠️  Не удалось скопировать $file"
    fi
done

# Копируем директорию tests
if [ -d "tests" ]; then
    echo "Копирование директории tests..."
    scp -r tests "$USERNAME@$REMOTE_HOST:$WIN_TEMP_DIR/" || echo "⚠️  Не удалось скопировать tests"
fi

# Перемещаем файлы из Windows в WSL
echo "📋 Перемещение файлов из Windows в WSL..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- cp -r /mnt/c/Users/$USERNAME/$WIN_TEMP_DIR/* \"$WSL_WORK_DIR/\""

# Создание директорий для отчетов в WSL
echo "📁 Создание директорий для отчетов в WSL..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- mkdir -p \"$WSL_WORK_DIR/playwright-report\" \"$WSL_WORK_DIR/test-results\""

# Запуск тестов в Docker через WSL
echo "🧪 Запуск тестов в Docker через WSL..."

echo "Проверка содержимого рабочей директории в WSL..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- ls -la \"$WSL_WORK_DIR\""

echo "Сборка Docker образа в WSL..."
if ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd \"$WSL_WORK_DIR\" && docker build -t playwright-tests .'"; then
    echo "✅ Docker образ собран успешно в WSL"

    echo "Запуск контейнера в WSL..."
    if ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- bash -c 'cd \"$WSL_WORK_DIR\" && docker run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \"\$(pwd)/playwright-report:/app/playwright-report\" -v \"\$(pwd)/test-results:/app/test-results\" playwright-tests'"; then
        echo "✅ Тесты выполнены успешно в Docker!"
    else
        echo "❌ Тесты завершились с ошибками!"
    fi
else
    echo "❌ Ошибка при сборке Docker образа в WSL!"
fi

# Копирование результатов обратно
echo "📥 Копирование результатов..."

# Копируем результаты из WSL обратно в Windows
echo "Копирование результатов из WSL в Windows..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- cp -r \"$WSL_WORK_DIR/playwright-report\" \"/mnt/c/Users/$USERNAME/$WIN_TEMP_DIR/\""
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- cp -r \"$WSL_WORK_DIR/test-results\" \"/mnt/c/Users/$USERNAME/$WIN_TEMP_DIR/\""

# Создаем локальные директории
mkdir -p playwright-report test-results

# Копируем результаты с Windows на локальную машину
echo "Копирование результатов с Windows сервера..."
scp -r "$USERNAME@$REMOTE_HOST:$WIN_TEMP_DIR/playwright-report/*" ./playwright-report/ 2>/dev/null || echo "Нет файлов отчетов"
scp -r "$USERNAME@$REMOTE_HOST:$WIN_TEMP_DIR/test-results/*" ./test-results/ 2>/dev/null || echo "Нет файлов результатов"

# Очистка
echo "🧹 Очистка..."
echo "Очистка WSL директории..."
ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $WSL_DISTRO -- rm -rf \"$WSL_WORK_DIR\"" || echo "⚠️  Не удалось очистить WSL директорию"

echo "Очистка Windows временной директории..."
ssh $USERNAME@$REMOTE_HOST "rmdir /s /q \"$WIN_TEMP_DIR\" 2>nul" || echo "⚠️  Не удалось очистить Windows директорию"

echo "🎉 Готово!"
echo "📊 Отчеты: playwright-report/"
echo "📋 Результаты: test-results/"

if [ -f "playwright-report/index.html" ]; then
    echo "🌐 Просмотр отчета: open playwright-report/index.html"
fi

echo ""
echo "ℹ️  Информация о процессе:"
echo "   1. Файлы скопированы на Windows сервер"
echo "   2. Файлы перемещены в WSL ($WSL_DISTRO)"
echo "   3. Docker образ собран в WSL"
echo "   4. Тесты выполнены в Docker контейнере"
echo "   5. Результаты скопированы обратно через Windows"
