#!/bin/bash
set -e

# Обновление системы
sudo apt-get update

# Установка Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Проверка версий
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Переход в рабочую директорию
cd /mnt/persist/workspace

# Установка зависимостей проекта
npm ci

# Установка браузеров Playwright с системными зависимостями
npx playwright install --with-deps

# Добавление npx в PATH (если нужно)
echo 'export PATH="$PATH:./node_modules/.bin"' >> $HOME/.profile

# Проверка установки Playwright
npx playwright --version