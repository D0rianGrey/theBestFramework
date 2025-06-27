#!/bin/bash

# Скрипт для запуска тестов на Windows сервере с Mac через SSH и PowerShell

# Настройки по умолчанию
REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}
BASE_URL=${BASE_URL_UI_TESTING:-"https://example.com"}

echo "🚀 Запуск тестов Playwright на Windows сервере"
echo "Сервер: $REMOTE_HOST"
echo "Пользователь: $USERNAME"
echo "Base URL: $BASE_URL"
echo "----------------------------------------"

# Проверка соединения с Windows сервером
echo "🔍 Проверка соединения с Windows сервером..."
if ! ssh $USERNAME@$REMOTE_HOST "echo 'Соединение установлено'"; then
    echo "❌ Ошибка соединения с $REMOTE_HOST"
    echo "Убедитесь что:"
    echo "1. SSH сервер запущен на Windows (OpenSSH Server)"
    echo "2. Правильные учетные данные"
    echo "3. Сервер доступен по сети"
    exit 1
fi

echo "✅ Соединение с Windows сервером установлено"

# Создание временной директории на Windows сервере
echo "📁 Создание временной директории на Windows сервере..."

# Попробуем разные способы создания временной директории
REMOTE_TEMP_DIR=$(ssh $USERNAME@$REMOTE_HOST "cmd /c 'echo %TEMP%\\playwright-tests-%RANDOM%' && mkdir %TEMP%\\playwright-tests-%RANDOM% >nul 2>&1 && echo %TEMP%\\playwright-tests-%RANDOM%" 2>/dev/null | head -1)

# Если не получилось, попробуем PowerShell
if [ -z "$REMOTE_TEMP_DIR" ] || [[ "$REMOTE_TEMP_DIR" == *"command not found"* ]]; then
    echo "Пробуем PowerShell..."
    REMOTE_TEMP_DIR=$(ssh $USERNAME@$REMOTE_HOST "powershell.exe -Command \"Join-Path \\\$env:TEMP 'playwright-tests-\\\$(Get-Date -Format \\\"yyyyMMdd-HHmmss\\\")'; New-Item -ItemType Directory -Path \\\$_ -Force | Select-Object -ExpandProperty FullName\"" 2>/dev/null)
fi

# Если и это не сработало, используем простой подход
if [ -z "$REMOTE_TEMP_DIR" ] || [[ "$REMOTE_TEMP_DIR" == *"command not found"* ]]; then
    echo "Используем простое создание директории..."
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    REMOTE_TEMP_DIR="C:\\temp\\playwright-tests-$TIMESTAMP"
    ssh $USERNAME@$REMOTE_HOST "mkdir \"$REMOTE_TEMP_DIR\" >nul 2>&1 || md \"$REMOTE_TEMP_DIR\" >nul 2>&1"
fi

if [ -z "$REMOTE_TEMP_DIR" ]; then
    echo "❌ Не удалось создать временную директорию"
    exit 1
fi

echo "✅ Создана временная директория: $REMOTE_TEMP_DIR"

# Копирование файлов проекта на Windows сервер
echo "📤 Копирование файлов проекта на Windows сервер..."

# Создание списка файлов для копирования
FILES_TO_COPY=(
    "package.json"
    "package-lock.json"
    "playwright.config.ts"
    "Dockerfile"
    ".env"
)

# Копирование отдельных файлов
for file in "${FILES_TO_COPY[@]}"; do
    if [ -f "$file" ]; then
        echo "Копирование $file..."
        scp "$file" "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/"
    fi
done

# Копирование директории tests
if [ -d "tests" ]; then
    echo "Копирование директории tests..."
    scp -r tests "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/"
fi

# Создание директорий для отчетов на Windows сервере
echo "📁 Создание директорий для отчетов..."

# Попробуем разные способы создания директорий
if ! ssh $USERNAME@$REMOTE_HOST "mkdir \"$REMOTE_TEMP_DIR\\playwright-report\" \"$REMOTE_TEMP_DIR\\test-results\" >nul 2>&1"; then
    # Если mkdir не сработал, попробуем md
    if ! ssh $USERNAME@$REMOTE_HOST "md \"$REMOTE_TEMP_DIR\\playwright-report\" >nul 2>&1 && md \"$REMOTE_TEMP_DIR\\test-results\" >nul 2>&1"; then
        # Если и md не сработал, попробуем PowerShell
        ssh $USERNAME@$REMOTE_HOST "powershell.exe -Command \"
            New-Item -ItemType Directory -Path '$REMOTE_TEMP_DIR\\playwright-report' -Force | Out-Null;
            New-Item -ItemType Directory -Path '$REMOTE_TEMP_DIR\\test-results' -Force | Out-Null;
            Write-Host 'Директории для отчетов созданы'
        \"" || echo "⚠️  Предупреждение: Не удалось создать директории для отчетов"
    fi
fi

# Запуск тестов на Windows сервере
echo "🧪 Запуск тестов на Windows сервере..."
echo "Это может занять несколько минут..."

# Сначала попробуем через PowerShell
echo "Пробуем запуск через PowerShell..."
TEST_RESULT=$(ssh $USERNAME@$REMOTE_HOST "powershell.exe -Command \"
    Set-Location '$REMOTE_TEMP_DIR';
    Write-Host 'Текущая директория: \\\$(Get-Location)';

    # Сборка образа
    Write-Host 'Сборка Podman образа...';
    \\\$buildResult = & podman build -t playwright-tests .;

    if (\\\$LASTEXITCODE -ne 0) {
        Write-Host 'Ошибка при сборке образа';
        exit 1;
    }

    Write-Host 'Образ собран успешно';

    # Запуск контейнера
    Write-Host 'Запуск контейнера с тестами...';
    \\\$runResult = & podman run --rm \\\`
        -e BASE_URL_UI_TESTING='$BASE_URL' \\\`
        -e CONTAINER=true \\\`
        -v \\\"\\\${PWD}\\\\playwright-report:/app/playwright-report\\\" \\\`
        -v \\\"\\\${PWD}\\\\test-results:/app/test-results\\\" \\\`
        playwright-tests;

    if (\\\$LASTEXITCODE -eq 0) {
        Write-Host 'Тесты выполнены успешно!';
        exit 0;
    } else {
        Write-Host 'Тесты завершились с ошибками!';
        exit 1;
    }
\"" 2>&1)

# Если PowerShell не сработал, попробуем через CMD
if [ $? -ne 0 ] || [[ "$TEST_RESULT" == *"command not found"* ]]; then
    echo "PowerShell не сработал, пробуем через CMD..."

    # Переходим в директорию и запускаем команды
    ssh $USERNAME@$REMOTE_HOST "cd /d \"$REMOTE_TEMP_DIR\" && echo Текущая директория: %CD%"

    echo "Сборка Podman образа..."
    if ssh $USERNAME@$REMOTE_HOST "cd /d \"$REMOTE_TEMP_DIR\" && podman build -t playwright-tests ."; then
        echo "✅ Образ собран успешно"

        echo "Запуск контейнера с тестами..."
        if ssh $USERNAME@$REMOTE_HOST "cd /d \"$REMOTE_TEMP_DIR\" && podman run --rm -e BASE_URL_UI_TESTING=$BASE_URL -e CONTAINER=true -v \"%CD%\\playwright-report:/app/playwright-report\" -v \"%CD%\\test-results:/app/test-results\" playwright-tests"; then
            echo "✅ Тесты выполнены успешно!"
            TEST_SUCCESS=true
        else
            echo "❌ Тесты завершились с ошибками!"
            TEST_SUCCESS=false
        fi
    else
        echo "❌ Ошибка при сборке образа!"
        TEST_SUCCESS=false
    fi
else
    echo "✅ Тесты выполнены через PowerShell!"
    TEST_SUCCESS=true
fi

# Копирование результатов тестов обратно на Mac
echo "📥 Копирование результатов тестов обратно..."

# Создание локальных директорий
mkdir -p playwright-report test-results

# Копирование результатов
echo "Копирование playwright-report..."
scp -r "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/playwright-report/*" ./playwright-report/ 2>/dev/null || echo "Нет файлов в playwright-report"

echo "Копирование test-results..."
scp -r "$USERNAME@$REMOTE_HOST:$REMOTE_TEMP_DIR/test-results/*" ./test-results/ 2>/dev/null || echo "Нет файлов в test-results"

# Очистка временной директории на Windows сервере
echo "🧹 Очистка временной директории на Windows сервере..."

# Попробуем разные способы удаления
if ! ssh $USERNAME@$REMOTE_HOST "rmdir /s /q \"$REMOTE_TEMP_DIR\" >nul 2>&1"; then
    # Если rmdir не сработал, попробуем PowerShell
    ssh $USERNAME@$REMOTE_HOST "powershell.exe -Command \"Remove-Item -Path '$REMOTE_TEMP_DIR' -Recurse -Force -ErrorAction SilentlyContinue\"" 2>/dev/null || echo "⚠️  Предупреждение: Не удалось очистить временную директорию"
fi

echo "🎉 Готово! Результаты тестов доступны в директориях:"
echo "   📊 playwright-report/"
echo "   📋 test-results/"

# Открытие отчета (если есть)
if [ -f "playwright-report/index.html" ]; then
    echo ""
    echo "🌐 Для просмотра отчета выполните:"
    echo "   open playwright-report/index.html"
fi
