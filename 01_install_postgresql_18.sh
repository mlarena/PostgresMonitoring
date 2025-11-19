#!/bin/bash

# Скрипт установки PostgreSQL 18 на Debian 12
# Требует права root для выполнения

set -e  # Прерывать выполнение при ошибках

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Этот скрипт требует права root. Используйте: sudo $0"
    exit 1
fi

echo "Установка PostgreSQL 18 на Debian 12..."

# Обновление системы
echo "Обновление списка пакетов..."
apt update

echo "Обновление установленных пакетов..."
apt upgrade -y

# Установка зависимостей
echo "Установка необходимых зависимостей..."
apt install -y wget curl gnupg sudo

# Добавление официального репозитория PostgreSQL
echo "Добавление репозитория PostgreSQL..."
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Обновление списка пакетов с новым репозиторием
echo "Обновление списка пакетов..."
apt update

# Установка PostgreSQL 18
echo "Установка PostgreSQL 18..."
apt install -y postgresql-18 postgresql-client-18

# Установка пароля для пользователя postgres
echo "Установка пароля для пользователя postgres..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '12345678';"

# Включение автозапуска
echo "Включение автозапуска PostgreSQL..."
systemctl enable postgresql@18-main

# Проверка статуса
echo "Проверка статуса PostgreSQL..."
systemctl status postgresql@18-main --no-pager

echo "Установка завершена!"
echo "Пароль пользователя postgres: 12345678"
echo "Для подключения: sudo -u postgres psql"