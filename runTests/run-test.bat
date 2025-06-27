@echo off
REM Batch скрипт для запуска тестов Playwright в Podman на Windows

echo Проверка и создание директорий для отчетов...

REM Создание директорий если они не существуют
if not exist "playwright-report" (
    echo Создание директории playwright-report...
    mkdir "playwright-report"
)

if not exist "test-results" (
    echo Создание директории test-results...
    mkdir "test-results"
)

REM Установка переменной BASE_URL если она не задана
if "%BASE_URL_UI_TESTING%"=="" (
    set BASE_URL_UI_TESTING=https://example.com
)

echo Сборка Docker образа...
podman build -t playwright-tests .

if %ERRORLEVEL% neq 0 (
    echo Ошибка при сборке образа!
    exit /b 1
)

echo Запуск контейнера с тестами...
echo BASE_URL: %BASE_URL_UI_TESTING%

REM Запуск контейнера с монтированием томов
podman run --rm ^
    -e BASE_URL_UI_TESTING=%BASE_URL_UI_TESTING% ^
    -e CONTAINER=true ^
    -v "%CD%\playwright-report:/app/playwright-report" ^
    -v "%CD%\test-results:/app/test-results" ^
    playwright-tests

if %ERRORLEVEL% equ 0 (
    echo Тесты выполнены успешно!
    echo Результаты доступны в директориях playwright-report и test-results
) else (
    echo Тесты завершились с ошибками!
    exit /b 1
)

pause
