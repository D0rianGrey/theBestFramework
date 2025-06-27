# Полезные команды Playwright для консоли

## 🚀 Установка и настройка

```bash
# Установка Playwright
npm init playwright@latest

# Установка только пакета (если уже есть проект)
npm install -D @playwright/test

# Установка браузеров
npx playwright install

# Установка браузеров с системными зависимостями (Linux)
npx playwright install --with-deps

# Установка конкретного браузера
npx playwright install chromium
npx playwright install firefox
npx playwright install webkit
```

## 🧪 Запуск тестов

```bash
# Запуск всех тестов
npx playwright test

# Запуск тестов в headed режиме (с GUI браузера)
npx playwright test --headed

# Запуск конкретного файла теста
npx playwright test tests/example.spec.ts

# Запуск конкретного теста по названию
npx playwright test --grep "название теста"

# Запуск тестов с определенным тегом
npx playwright test --grep "@smoke"

# Запуск в конкретном браузере
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit

# Запуск в debug режиме
npx playwright test --debug

# Запуск с максимальным количеством неудач
npx playwright test --max-failures=1

# Запуск только упавших тестов
npx playwright test --last-failed

# Запуск тестов параллельно
npx playwright test --workers=4

# Запуск тестов последовательно
npx playwright test --workers=1
```

## 🔍 Отладка и разработка

```bash
# Открыть Playwright Inspector для отладки
npx playwright test --debug

# Запуск в режиме пошаговой отладки
npx playwright test --debug --headed

# Генерация кода тестов (Codegen)
npx playwright codegen

# Codegen для конкретного сайта
npx playwright codegen https://example.com

# Codegen с сохранением в файл
npx playwright codegen --target javascript -o tests/generated.spec.js https://example.com

# Codegen с эмуляцией устройства
npx playwright codegen --device="iPhone 12" https://example.com

# Trace viewer (просмотр трейсов)
npx playwright show-trace trace.zip

# Открыть HTML отчет
npx playwright show-report
```

## 📊 Отчеты и результаты

```bash
# Запуск с HTML отчетом
npx playwright test --reporter=html

# Запуск с JSON отчетом
npx playwright test --reporter=json

# Запуск с JUnit отчетом
npx playwright test --reporter=junit

# Запуск с несколькими репортерами
npx playwright test --reporter=list,html,json

# Открыть последний HTML отчет
npx playwright show-report

# Открыть конкретный HTML отчет
npx playwright show-report playwright-report
```

## 🖼️ Скриншоты и видео

```bash
# Запуск с записью видео
npx playwright test --video=on

# Запуск с записью видео только для упавших тестов
npx playwright test --video=retain-on-failure

# Запуск со скриншотами
npx playwright test --screenshot=on

# Запуск со скриншотами только для упавших тестов
npx playwright test --screenshot=only-on-failure

# Запуск с трейсингом
npx playwright test --trace=on

# Запуск с трейсингом только для упавших тестов
npx playwright test --trace=retain-on-failure
```

## 🌐 Работа с браузерами

```bash
# Список установленных браузеров
npx playwright install --dry-run

# Информация о системе
npx playwright --version

# Проверка системных требований
npx playwright install --dry-run --with-deps
```

## ⚙️ Конфигурация

```bash
# Запуск с конкретным конфигом
npx playwright test --config=playwright.config.ts

# Запуск с переменными окружения
BASE_URL=https://staging.example.com npx playwright test

# Запуск с глобальными переменными
npx playwright test --global-timeout=60000
```

## 🔧 Полезные флаги

```bash
# Показать подробный вывод
npx playwright test --verbose

# Тихий режим (минимум вывода)
npx playwright test --quiet

# Показать браузер во время выполнения
npx playwright test --headed

# Замедлить выполнение (в миллисекундах)
npx playwright test --slowMo=1000

# Установить таймаут для тестов
npx playwright test --timeout=30000

# Повторить упавшие тесты
npx playwright test --retries=2

# Запуск с игнорированием HTTPS ошибок
npx playwright test --ignore-https-errors
```

## 📱 Мобильная эмуляция

```bash
# Запуск с эмуляцией iPhone
npx playwright test --project="Mobile Chrome"

# Codegen для мобильного устройства
npx playwright codegen --device="iPhone 12 Pro" https://example.com
```

## 🎯 Фильтрация тестов

```bash
# Запуск тестов по пути
npx playwright test tests/auth/

# Запуск тестов по паттерну в названии файла
npx playwright test "**/*auth*.spec.ts"

# Исключение тестов
npx playwright test --grep-invert "skip this test"

# Запуск только тестов с определенным тегом
npx playwright test --grep "@critical"
```

## 🚨 Примеры комбинированных команд

```bash
# Полная отладка с видео и трейсами
npx playwright test --headed --debug --video=on --trace=on

# Быстрый прогон критических тестов
npx playwright test --grep "@smoke" --workers=4 --reporter=list

# Детальная отладка конкретного теста
npx playwright test tests/login.spec.ts --headed --debug --slowMo=500

# Прогон с полными отчетами
npx playwright test --reporter=html,json --video=retain-on-failure --screenshot=only-on-failure
```

## 💡 Полезные советы

- Используйте `--headed` для визуальной отладки
- `--debug` останавливает выполнение и открывает инспектор
- `--trace=on` создает детальные трейсы для анализа
- `--workers=1` полезно для отладки race conditions
- `--max-failures=1` останавливает выполнение после первой ошибки
- Используйте переменные окружения для разных сред (dev, staging, prod)

## 🌐 Запуск тестов на удаленном сервере

### Linux/macOS (SSH)
```bash
# Запуск тестов на удаленном сервере через SSH
./run-remote-docker.sh

# Запуск с указанием конкретного хоста
REMOTE_HOST="user@server.com" ./run-remote-docker.sh

# Запуск с указанием пути к SSH-ключу
REMOTE_HOST="user@server.com" SSH_KEY="~/.ssh/custom_key" ./run-remote-docker.sh

# Запуск с указанием базового URL
REMOTE_HOST="user@server.com" BASE_URL_UI_TESTING="https://staging.example.com" ./run-remote-docker.sh
```

### Windows (PowerShell Remoting)
```powershell
# Запуск тестов на удаленном Windows сервере через PowerShell Remoting
.\runTests\run-remote-windows.ps1

# Запуск с параметрами
.\runTests\run-remote-windows.ps1 -RemoteHost "192.168.1.100" -Username "Administrator" -BaseUrl "https://staging.example.com"

# Настройка PowerShell Remoting на удаленном сервере (выполнить один раз)
# На удаленном сервере:
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Настройка WinRM для HTTP (если нужно)
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

### Mac/Linux → Windows (SSH)
```bash
# Запуск тестов на Windows сервере с Mac/Linux через SSH
./runTests/run-remote-windows-from-mac.sh

# Запуск с параметрами
REMOTE_HOST="192.168.1.100" USERNAME="yevhenii" BASE_URL_UI_TESTING="https://staging.example.com" ./runTests/run-remote-windows-from-mac.sh

# Простая версия (более совместимая)
./runTests/run-remote-windows-simple.sh

# Базовая версия (для проблемных систем)
./runTests/run-remote-windows-basic.sh

# Настройка OpenSSH на Windows сервере (выполнить один раз)
# На Windows сервере в PowerShell от администратора:
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## 🔄 Шардирование тестов (распределение между несколькими машинами)

```bash
# Запуск первого шарда из четырех
npx playwright test --shard=1/4

# Запуск второго шарда из четырех
npx playwright test --shard=2/4

# Запуск с шардированием и отчетом в формате blob
npx playwright test --shard=1/3 --reporter=blob

# Объединение отчетов из разных шардов
npx playwright merge-reports --reporter html ./all-blob-reports
```

## 🐳 Запуск в Docker/Podman

### Linux/macOS
```bash
# Сборка Docker образа
docker build -t playwright-tests .

# Запуск тестов в Docker
docker run --rm -v "$(pwd)/playwright-report:/app/playwright-report" playwright-tests

# Запуск с переменными окружения
docker run --rm -e BASE_URL_UI_TESTING="https://example.com" -v "$(pwd)/playwright-report:/app/playwright-report" playwright-tests

# Запуск с Podman (Linux)
./run-test.sh
```

### Windows
```powershell
# PowerShell - сборка образа
podman build -t playwright-tests .

# PowerShell - запуск тестов
podman run --rm `
    -e BASE_URL_UI_TESTING="https://example.com" `
    -v "${PWD}\playwright-report:/app/playwright-report" `
    -v "${PWD}\test-results:/app/test-results" `
    playwright-tests

# Запуск готовых скриптов
.\runTests\run-test.ps1      # PowerShell скрипт
.\runTests\run-test.bat      # Batch файл
.\runTests\run-test.sh       # Bash скрипт (если есть WSL/Git Bash)
```

```cmd
REM CMD - сборка образа
podman build -t playwright-tests .

REM CMD - запуск тестов
podman run --rm ^
    -e BASE_URL_UI_TESTING=https://example.com ^
    -v "%CD%\playwright-report:/app/playwright-report" ^
    -v "%CD%\test-results:/app/test-results" ^
    playwright-tests
```

## 📁 Доступные скрипты в директории runTests/

### Локальный запуск
```bash
./runTests/run-test.sh       # Bash скрипт для Linux/macOS/WSL
./runTests/run-test.ps1      # PowerShell скрипт для Windows
./runTests/run-test.bat      # Batch файл для Windows CMD
```

### Удаленный запуск на Linux/macOS сервере
```bash
./run-remote-docker.sh                        # SSH + Docker/Podman на Linux/macOS
./runTests/run-remote-linux-universal.sh      # Универсальный (Linux/WSL)
./runTests/run-remote-wsl-as-linux.sh         # WSL как Linux сервер
```

### Диагностика и проверка
```bash
./runTests/check-wsl-remote.sh                # Диагностика WSL на удаленном сервере
```

### Удаленный запуск на Windows сервере
```bash
# С Mac/Linux на Windows сервер (Podman)
./runTests/run-remote-windows-from-mac.sh    # Полнофункциональная версия
./runTests/run-remote-windows-simple.sh      # Упрощенная версия
./runTests/run-remote-windows-basic.sh       # Базовая версия (для проблемных систем)

# С Mac/Linux на Windows сервер (Docker в WSL)
./runTests/run-remote-wsl-docker.sh          # Docker в WSL (полная версия)
./runTests/run-remote-wsl-docker-simple.sh   # Docker в WSL (упрощенная версия)

# С Windows на Windows сервер
./runTests/run-remote-windows.ps1            # PowerShell Remoting
```

### Выбор скрипта для удаленного Windows:

#### Podman на Windows:
- **run-remote-windows-from-mac.sh** - если на сервере есть PowerShell и все работает
- **run-remote-windows-simple.sh** - если есть проблемы с PowerShell
- **run-remote-windows-basic.sh** - если ничего не работает (использует только базовые команды)

#### Docker в WSL:
- **run-remote-wsl-as-linux.sh** - WSL как Linux сервер (РЕКОМЕНДУЕТСЯ)
- **run-remote-linux-universal.sh** - универсальный Linux/WSL скрипт
- **run-remote-wsl-docker.sh** - полная версия с детальным контролем
- **run-remote-wsl-docker-simple.sh** - упрощенная версия с архивами

### Требования для удаленного запуска на Windows:

#### Для Podman:
1. **OpenSSH Server** установлен и запущен
2. **Podman** установлен и доступен в PATH
3. **Доступ по SSH** с ключом или паролем

#### Для Docker в WSL:
1. **OpenSSH Server** установлен и запущен на Windows
2. **WSL** установлен и настроен
3. **Docker** установлен в WSL дистрибутиве
4. **Docker daemon** запущен в WSL
5. **Доступ по SSH** с ключом или паролем

### Примеры использования:
```bash
# Диагностика WSL (если есть проблемы)
./runTests/check-wsl-remote.sh

# WSL как Linux сервер (РЕКОМЕНДУЕТСЯ для WSL)
./runTests/run-remote-wsl-as-linux.sh
REMOTE_HOST="yevhenii@192.168.195.211" ./runTests/run-remote-wsl-as-linux.sh

# Универсальный Linux/WSL
./runTests/run-remote-linux-universal.sh
CONTAINER_ENGINE="docker" REMOTE_HOST="yevhenii@192.168.195.211" ./runTests/run-remote-linux-universal.sh

# Podman на Windows
./runTests/run-remote-windows-basic.sh
REMOTE_HOST="192.168.195.211" USERNAME="yevhenii" ./runTests/run-remote-windows-basic.sh

# Docker в WSL (сложный способ)
./runTests/run-remote-wsl-docker-simple.sh
WSL_DISTRO="Ubuntu" REMOTE_HOST="192.168.195.211" ./runTests/run-remote-wsl-docker.sh

# Локальный запуск на Windows
.\runTests\run-test.ps1

# Удаленный запуск через PowerShell Remoting
.\runTests\run-remote-windows.ps1 -RemoteHost "192.168.1.100" -Username "Administrator"
```

### Настройка Docker в WSL на Windows сервере:
```bash
# На Windows сервере в PowerShell от администратора:
# 1. Установка WSL
wsl --install

# 2. Установка Ubuntu (или другого дистрибутива)
wsl --install -d Ubuntu

# 3. В WSL установка Docker
wsl -d Ubuntu
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 4. Запуск Docker daemon при старте WSL
echo 'sudo service docker start' >> ~/.bashrc
```

## 🎯 Быстрый старт для WSL

### Если у вас Windows с WSL:
```bash
# 1. Проверьте WSL на удаленном сервере
./runTests/check-wsl-remote.sh

# 2. Если WSL настроен, используйте простой подход
./runTests/run-remote-wsl-as-linux.sh

# 3. Если нужна универсальность (Linux + WSL)
./runTests/run-remote-linux-universal.sh
```

### Если WSL не настроен:
```bash
# Используйте Podman на Windows
./runTests/run-remote-windows-basic.sh
```

### Приоритет выбора скриптов:
1. **WSL как Linux** → `run-remote-wsl-as-linux.sh` (самый простой)
2. **Универсальный** → `run-remote-linux-universal.sh` (Linux + WSL)
3. **Podman Windows** → `run-remote-windows-basic.sh` (если нет WSL)
4. **Сложные WSL** → `run-remote-wsl-docker.sh` (только если нужен контроль)
