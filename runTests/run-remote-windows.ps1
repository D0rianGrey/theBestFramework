# PowerShell скрипт для запуска тестов на удаленном Windows сервере

param(
    [string]$RemoteHost = "192.168.195.211",
    [string]$Username = "yevhenii",
    [string]$BaseUrl = "https://example.com"
)

# Настройки удаленного сервера
$RemoteSession = $null

try {
    Write-Host "Подключение к удаленному серверу $RemoteHost..." -ForegroundColor Yellow
    
    # Создание PSSession для удаленного подключения
    $RemoteSession = New-PSSession -ComputerName $RemoteHost -Credential (Get-Credential -UserName $Username -Message "Введите пароль для $Username")
    
    if (!$RemoteSession) {
        throw "Не удалось установить соединение с $RemoteHost"
    }
    
    Write-Host "Соединение установлено успешно!" -ForegroundColor Green
    
    # Создание временной директории на удаленном сервере
    $RemoteTempDir = Invoke-Command -Session $RemoteSession -ScriptBlock {
        $tempDir = Join-Path $env:TEMP "playwright-tests-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        return $tempDir
    }
    
    Write-Host "Создана временная директория: $RemoteTempDir" -ForegroundColor Cyan
    
    # Копирование файлов проекта на удаленный сервер
    Write-Host "Копирование файлов проекта на удаленный сервер..." -ForegroundColor Yellow
    
    # Список файлов для копирования (исключаем ненужные)
    $FilesToCopy = @(
        "package.json",
        "package-lock.json", 
        "playwright.config.ts",
        "Dockerfile",
        ".env"
    )
    
    # Копирование отдельных файлов
    foreach ($file in $FilesToCopy) {
        if (Test-Path $file) {
            Copy-Item -Path $file -Destination $RemoteTempDir -ToSession $RemoteSession
        }
    }
    
    # Копирование директории tests
    if (Test-Path "tests") {
        Copy-Item -Path "tests" -Destination $RemoteTempDir -Recurse -ToSession $RemoteSession
    }
    
    # Создание директорий для отчетов на удаленном сервере
    Write-Host "Создание директорий для отчетов на удаленном сервере..." -ForegroundColor Yellow
    Invoke-Command -Session $RemoteSession -ScriptBlock {
        param($tempDir)
        New-Item -ItemType Directory -Path "$tempDir\playwright-report" -Force | Out-Null
        New-Item -ItemType Directory -Path "$tempDir\test-results" -Force | Out-Null
    } -ArgumentList $RemoteTempDir
    
    # Запуск Podman на удаленном сервере
    Write-Host "Запуск тестов на удаленном сервере..." -ForegroundColor Yellow
    $TestResult = Invoke-Command -Session $RemoteSession -ScriptBlock {
        param($tempDir, $baseUrl)
        
        Set-Location $tempDir
        
        # Сборка образа
        Write-Host "Сборка образа..."
        $buildResult = & podman build -t playwright-tests .
        
        if ($LASTEXITCODE -ne 0) {
            return @{ Success = $false; Message = "Ошибка при сборке образа" }
        }
        
        # Запуск контейнера
        Write-Host "Запуск контейнера..."
        $runResult = & podman run --rm `
            -e BASE_URL_UI_TESTING=$baseUrl `
            -e CONTAINER=true `
            -v "${tempDir}\playwright-report:/app/playwright-report" `
            -v "${tempDir}\test-results:/app/test-results" `
            playwright-tests
            
        return @{ Success = ($LASTEXITCODE -eq 0); Message = "Тесты выполнены" }
        
    } -ArgumentList $RemoteTempDir, $BaseUrl
    
    if ($TestResult.Success) {
        Write-Host "Тесты выполнены успешно!" -ForegroundColor Green
    } else {
        Write-Host "Ошибка при выполнении тестов: $($TestResult.Message)" -ForegroundColor Red
    }
    
    # Копирование результатов тестов обратно
    Write-Host "Копирование результатов тестов обратно..." -ForegroundColor Yellow
    
    # Создание локальных директорий
    if (!(Test-Path "playwright-report")) { New-Item -ItemType Directory -Path "playwright-report" -Force }
    if (!(Test-Path "test-results")) { New-Item -ItemType Directory -Path "test-results" -Force }
    
    # Копирование результатов
    Copy-Item -Path "$RemoteTempDir\playwright-report\*" -Destination "playwright-report\" -Recurse -FromSession $RemoteSession -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$RemoteTempDir\test-results\*" -Destination "test-results\" -Recurse -FromSession $RemoteSession -Force -ErrorAction SilentlyContinue
    
    # Очистка временной директории
    Write-Host "Очистка временной директории на удаленном сервере..." -ForegroundColor Yellow
    Invoke-Command -Session $RemoteSession -ScriptBlock {
        param($tempDir)
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    } -ArgumentList $RemoteTempDir
    
    Write-Host "Тесты выполнены. Результаты доступны в директориях playwright-report и test-results." -ForegroundColor Green
    
} catch {
    Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Закрытие удаленной сессии
    if ($RemoteSession) {
        Remove-PSSession -Session $RemoteSession
        Write-Host "Соединение с удаленным сервером закрыто." -ForegroundColor Cyan
    }
}
