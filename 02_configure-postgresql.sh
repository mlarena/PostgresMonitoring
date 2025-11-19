#!/bin/bash
# configure-postgresql.sh

set -e

echo "=== Настройка PostgreSQL ==="

# Показать текущую конфигурацию
echo "1. Текущий конфиг файл:"
sudo -u postgres psql -c "SHOW config_file;"

echo -e "\n2. Основные параметры:"
sudo -u postgres psql -c "SHOW listen_addresses;"
sudo -u postgres psql -c "SHOW port;"
sudo -u postgres psql -c "SHOW max_connections;"

# Изменение конфигурации
read -p "Хотите изменить конфигурацию? (y/n): " CHANGE_CONFIG

if [[ $CHANGE_CONFIG =~ ^[Yy]$ ]]; then
    echo "Редактирование конфигурации..."
    sudo nano /etc/postgresql/18/main/postgresql.conf
    echo "Перезагрузка конфигурации..."
    sudo systemctl restart postgresql@18-main
    echo "Готово!"
fi