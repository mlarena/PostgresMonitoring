#!/bin/bash

set -e

echo "=== Настройка логирования PostgreSQL в JSON формате ==="

CONF_FILE="/etc/postgresql/18/main/postgresql.conf"
LOG_CONF_FILE="/etc/postgresql/18/main/conf.d/01-logging.conf"

# Проверяем текущие настройки
echo "Текущие настройки логирования:"
sudo -u postgres psql -c "SHOW log_destination;"
sudo -u postgres psql -c "SHOW log_filename;"

# Создаем директорию для дополнительных конфигов если не существует
if [ ! -d "/etc/postgresql/18/main/conf.d" ]; then
    echo "Создаем директорию conf.d..."
    mkdir -p /etc/postgresql/18/main/conf.d
    chown postgres:postgres /etc/postgresql/18/main/conf.d
fi

# Создаем файл с настройками логирования в JSON формате
echo "Создаем файл конфигурации логирования в JSON формате..."
cat > $LOG_CONF_FILE << 'EOF'
# =============================================
# НАСТРОЙКИ ЛОГИРОВАНИЯ PostgreSQL в JSON
# =============================================

# Основные настройки логирования
log_destination = 'jsonlog'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 7d
log_rotation_size = 100MB

# Что логировать
log_statement = 'all'
log_min_duration_statement = 0
log_connections = on
log_disconnections = on
log_lock_waits = on
log_autovacuum_min_duration = 0

# Формат и детализация логов
log_timezone = 'UTC'
log_min_messages = 'info'
log_checkpoints = on
log_temp_files = 0
log_error_verbosity = 'verbose'
EOF

# Устанавливаем правильные права
chown postgres:postgres $LOG_CONF_FILE
chmod 644 $LOG_CONF_FILE

echo "Файл конфигурации создан: $LOG_CONF_FILE"

# Очищаем старые логи
echo "Очищаем старые логи..."
PG_DATA_DIR="/var/lib/postgresql/18/main"
rm -f $PG_DATA_DIR/log/postgresql-*.json.*

# Перезапускаем PostgreSQL для применения настроек
echo "Перезапускаем PostgreSQL для применения настроек..."
systemctl restart postgresql@18-main

# Ждем запуска
sleep 3

# Проверяем статус
echo "Проверяем статус PostgreSQL..."
systemctl status postgresql@18-main --no-pager

# Проверяем новые настройки
echo "Новые настройки логирования:"
sudo -u postgres psql -c "SHOW log_destination;"
sudo -u postgres psql -c "SHOW log_filename;"

# Тестируем логирование
echo "Тестируем логирование..."
sudo -u postgres psql -c "SELECT 'Test JSON logging after fix';"

# Проверяем созданные файлы
echo "Проверяем файлы логов:"
ls -la $PG_DATA_DIR/log/ 2>/dev/null || echo "Директория не найдена"

echo "=== Настройка завершена ==="
echo "Для просмотра JSON логов используйте:"
echo "sudo tail -f /var/lib/postgresql/18/main/log/postgresql-*.log"