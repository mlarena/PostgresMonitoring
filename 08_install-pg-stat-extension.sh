#!/bin/bash
# install-pg-stat-extension.sh

set -e

echo "=== Установка расширения pg_stat_statements в базы данных ==="

# Создаем расширение в основных базах данных
echo "Создаем расширение pg_stat_statements в базах данных..."
DATABASES=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" 2>/dev/null)

for db in $DATABASES; do
    db_clean=$(echo $db | xargs)  # Убираем лишние пробелы
    if [ -n "$db_clean" ]; then
        echo "Устанавливаем расширение в базу: $db_clean"
        sudo -u postgres psql -d "$db_clean" -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;" 2>/dev/null || echo "Не удалось установить в $db_clean"
    fi
done

echo "=== Установка расширений завершена ==="