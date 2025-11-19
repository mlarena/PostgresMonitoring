#!/bin/bash

set -e

echo "=== Настройка логирования PostgreSQL ==="

CONF_FILE="/etc/postgresql/18/main/postgresql.conf"
LOG_CONF_FILE="/etc/postgresql/18/main/conf.d/01-logging.conf"

# Проверяем текущие настройки
echo "Текущие настройки логирования:"
sudo -u postgres psql -c "SHOW logging_collector;"
sudo -u postgres psql -c "SHOW log_directory;"
sudo -u postgres psql -c "SHOW log_statement;"

# Создаем директорию для дополнительных конфигов если не существует
if [ ! -d "/etc/postgresql/18/main/conf.d" ]; then
    echo "Создаем директорию conf.d..."
    mkdir -p /etc/postgresql/18/main/conf.d
    chown postgres:postgres /etc/postgresql/18/main/conf.d
fi

# Создаем файл с настройками логирования
echo "Создаем файл конфигурации логирования..."
cat > $LOG_CONF_FILE << 'EOF'
# =============================================
# НАСТРОЙКИ ЛОГИРОВАНИЯ PostgreSQL
# =============================================

# Основные настройки логирования
log_destination = 'stderr'
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
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
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

# Создаем директорию для логов в data directory если не существует
PG_DATA_DIR="/var/lib/postgresql/18/main"
if [ ! -d "$PG_DATA_DIR/log" ]; then
    echo "Создаем директорию для логов в data directory..."
    mkdir -p $PG_DATA_DIR/log
    chown postgres:postgres $PG_DATA_DIR/log
fi

# Перезапускаем PostgreSQL для применения ВСЕХ настроек
echo "Перезапускаем PostgreSQL для применения настроек..."
systemctl restart postgresql@18-main

# Ждем запуска
sleep 3

# Проверяем статус
echo "Проверяем статус PostgreSQL..."
systemctl status postgresql@18-main --no-pager

# Проверяем новые настройки
echo "Новые настройки логирования:"
sudo -u postgres psql -c "SHOW logging_collector;"
sudo -u postgres psql -c "SHOW log_directory;"
sudo -u postgres psql -c "SHOW log_statement;"
sudo -u postgres psql -c "SHOW log_connections;"
sudo -u postgres psql -c "SHOW log_min_duration_statement;"

# Проверяем где создались логи
echo "Проверяем файлы логов:"
echo "В data directory:"
ls -la $PG_DATA_DIR/log/ 2>/dev/null || echo "Директория не найдена"
echo "В /var/log/postgresql/:"
ls -la /var/log/postgresql/ 2>/dev/null || echo "Директория не найдена"

echo "=== Настройка завершена ==="
echo "Проверьте логи в следующих местах:"
echo "1. /var/lib/postgresql/18/main/log/"
echo "2. /var/log/postgresql/"
echo ""
echo "Для просмотра логов используйте:"
echo "sudo find /var -name 'postgresql*.log' -type f 2>/dev/null"
echo "sudo tail -f /var/lib/postgresql/18/main/log/postgresql-*.log"
echo "sudo tail -f /var/log/postgresql/postgresql-*.log"