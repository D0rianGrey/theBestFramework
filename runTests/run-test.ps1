# PowerShell скрипт для запуска тестов Playwright в Podman на Windows

# Проверка и создание директорий для отчетов
if (!(Test-Path "playwright-report")) {
    Write-Host "Создание директории playwright-report..." -ForegroundColor Green
    New-Item -ItemType Directory -Path "playwright-report" -Force
}

if (!(Test-Path "test-results")) {
    Write-Host "Создание директории test-results..." -ForegroundColor Green
    New-Item -ItemType Directory -Path "test-results" -Force
}

# Получение переменной окружения или значения по умолчанию
$BASE_URL = if ($env:BASE_URL_UI_TESTING) { $env:BASE_URL_UI_TESTING } else { "https://example.com" }

Write-Host "Сборка Docker образа..." -ForegroundColor Yellow
podman build -t playwright-tests .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при сборке образа!" -ForegroundColor Red
    exit 1
}

Write-Host "Запуск контейнера с тестами..." -ForegroundColor Yellow
Write-Host "BASE_URL: $BASE_URL" -ForegroundColor Cyan

# Получение текущей директории в формате для Windows
$currentDir = (Get-Location).Path

podman run --rm `
    -e BASE_URL_UI_TESTING=$BASE_URL `
    -e CONTAINER=true `
    -v "${currentDir}\playwright-report:/app/playwright-report" `
    -v "${currentDir}\test-results:/app/test-results" `
    playwright-tests

if ($LASTEXITCODE -eq 0) {
    Write-Host "Тесты выполнены успешно!" -ForegroundColor Green
    Write-Host "Результаты доступны в директориях playwright-report и test-results" -ForegroundColor Green
} else {
    Write-Host "Тесты завершились с ошибками!" -ForegroundColor Red
    exit 1
}
