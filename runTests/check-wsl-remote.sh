#!/bin/bash

# Диагностический скрипт для проверки WSL на удаленном Windows сервере

REMOTE_HOST=${REMOTE_HOST:-"192.168.195.211"}
USERNAME=${USERNAME:-"yevhenii"}

echo "🔍 Диагностика WSL на удаленном Windows сервере"
echo "Сервер: $REMOTE_HOST"
echo "Пользователь: $USERNAME"
echo "=========================================="

# Проверка соединения
echo "1. Проверка SSH соединения..."
if ! ssh $USERNAME@$REMOTE_HOST "echo 'SSH работает'"; then
    echo "❌ Ошибка SSH соединения"
    exit 1
fi
echo "✅ SSH соединение работает"

# Проверка операционной системы
echo ""
echo "2. Проверка операционной системы..."
OS_INFO=$(ssh $USERNAME@$REMOTE_HOST "ver 2>/dev/null || uname -a 2>/dev/null || echo 'Unknown OS'")
echo "ОС: $OS_INFO"

# Проверка команды wsl
echo ""
echo "3. Проверка команды 'wsl'..."
WSL_HELP=$(ssh $USERNAME@$REMOTE_HOST "wsl --help 2>/dev/null || echo 'WSL_NOT_FOUND'")

if [[ "$WSL_HELP" == *"WSL_NOT_FOUND"* ]]; then
    echo "❌ Команда 'wsl' не найдена"
else
    if [[ "$WSL_HELP" == *"Wsman"* ]]; then
        echo "⚠️  Найдена команда 'wsl', но это Wsman Shell, а не Windows Subsystem for Linux"
        echo "Вывод команды 'wsl':"
        echo "$WSL_HELP" | head -10
    else
        echo "✅ Команда 'wsl' найдена"
    fi
fi

# Проверка команды wsl.exe
echo ""
echo "4. Проверка команды 'wsl.exe'..."
WSL_EXE_VERSION=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe --version 2>/dev/null || echo 'WSL_EXE_NOT_FOUND'")

if [[ "$WSL_EXE_VERSION" == *"WSL_EXE_NOT_FOUND"* ]]; then
    echo "❌ Команда 'wsl.exe' не найдена"
    echo "Windows Subsystem for Linux не установлен"
else
    echo "✅ Windows Subsystem for Linux найден"
    echo "Версия WSL:"
    echo "$WSL_EXE_VERSION"
fi

# Проверка доступных дистрибутивов
echo ""
echo "5. Проверка доступных WSL дистрибутивов..."
if [[ "$WSL_EXE_VERSION" != *"WSL_EXE_NOT_FOUND"* ]]; then
    WSL_DISTROS=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe -l -v 2>/dev/null || echo 'NO_DISTROS'")
    
    if [[ "$WSL_DISTROS" == *"NO_DISTROS"* ]]; then
        echo "❌ Не удалось получить список дистрибутивов"
    else
        echo "Доступные дистрибутивы:"
        echo "$WSL_DISTROS"
        
        # Проверка конкретных дистрибутивов
        echo ""
        echo "6. Проверка популярных дистрибутивов..."
        
        for distro in "Ubuntu" "Ubuntu-20.04" "Ubuntu-22.04" "Debian" "Alpine"; do
            echo "Проверка $distro..."
            DISTRO_CHECK=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $distro -- echo 'OK' 2>/dev/null || echo 'NOT_AVAILABLE'")
            
            if [[ "$DISTRO_CHECK" == "OK" ]]; then
                echo "✅ $distro доступен"
                
                # Проверка Docker в этом дистрибутиве
                DOCKER_CHECK=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $distro -- docker --version 2>/dev/null || echo 'NO_DOCKER'")
                
                if [[ "$DOCKER_CHECK" == *"NO_DOCKER"* ]]; then
                    echo "   ❌ Docker не установлен в $distro"
                else
                    echo "   ✅ Docker найден в $distro: $DOCKER_CHECK"
                    
                    # Проверка Docker daemon
                    DOCKER_STATUS=$(ssh $USERNAME@$REMOTE_HOST "wsl.exe -d $distro -- docker ps 2>/dev/null && echo 'DOCKER_RUNNING' || echo 'DOCKER_NOT_RUNNING'")
                    
                    if [[ "$DOCKER_STATUS" == *"DOCKER_RUNNING"* ]]; then
                        echo "   ✅ Docker daemon запущен в $distro"
                    else
                        echo "   ⚠️  Docker daemon не запущен в $distro"
                        echo "   Попробуйте: wsl.exe -d $distro -- sudo service docker start"
                    fi
                fi
            else
                echo "❌ $distro не доступен"
            fi
        done
    fi
else
    echo "❌ WSL не установлен, пропускаем проверку дистрибутивов"
fi

# Рекомендации
echo ""
echo "=========================================="
echo "📋 РЕКОМЕНДАЦИИ:"
echo ""

if [[ "$WSL_EXE_VERSION" == *"WSL_EXE_NOT_FOUND"* ]]; then
    echo "🔧 Для установки WSL на Windows сервере:"
    echo "   1. Откройте PowerShell от администратора"
    echo "   2. Выполните: wsl --install"
    echo "   3. Перезагрузите сервер"
    echo "   4. Выполните: wsl --install -d Ubuntu"
    echo ""
    echo "🔧 Для установки Docker в WSL:"
    echo "   1. wsl.exe -d Ubuntu"
    echo "   2. sudo apt update"
    echo "   3. sudo apt install docker.io"
    echo "   4. sudo systemctl start docker"
    echo "   5. sudo systemctl enable docker"
    echo "   6. sudo usermod -aG docker \$USER"
else
    echo "✅ WSL установлен"
    
    if [[ "$WSL_DISTROS" == *"Ubuntu"* ]]; then
        echo "✅ Ubuntu дистрибутив найден"
        echo "🔧 Для использования скриптов используйте:"
        echo "   ./runTests/run-remote-wsl-docker-simple.sh"
    else
        echo "⚠️  Ubuntu дистрибутив не найден"
        echo "🔧 Установите Ubuntu: wsl --install -d Ubuntu"
    fi
fi

echo ""
echo "🎯 После настройки попробуйте:"
echo "   ./runTests/run-remote-wsl-docker-simple.sh"
