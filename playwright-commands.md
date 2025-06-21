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

## 🐳 Запуск в Docker

```bash
# Сборка Docker образа
docker build -t playwright-tests .

# Запуск тестов в Docker
docker run --rm -v "$(pwd)/playwright-report:/app/playwright-report" playwright-tests

# Запуск с переменными окружения
docker run --rm -e BASE_URL_UI_TESTING="https://example.com" -v "$(pwd)/playwright-report:/app/playwright-report" playwright-tests
```
