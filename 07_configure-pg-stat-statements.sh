#!/bin/bash

set -e

echo "=== Настройка pg_stat_statements для PostgreSQL ==="

CONF_FILE="/etc/postgresql/18/main/postgresql.conf"
STATS_CONF_FILE="/etc/postgresql/18/main/conf.d/02-pg-stat-statements.conf"

# Проверяем текущие настройки
echo "Текущие настройки pg_stat_statements:"
sudo -u postgres psql -c "SHOW shared_preload_libraries;" 2>/dev/null || echo "Не удалось подключиться к PostgreSQL"

# Создаем директорию для дополнительных конфигов если не существует
if [ ! -d "/etc/postgresql/18/main/conf.d" ]; then
    echo "Создаем директорию conf.d..."
    mkdir -p /etc/postgresql/18/main/conf.d
    chown postgres:postgres /etc/postgresql/18/main/conf.d
fi

# Создаем файл с настройками pg_stat_statements
echo "Создаем файл конфигурации pg_stat_statements..."
cat > $STATS_CONF_FILE << 'EOF'
# =============================================
# НАСТРОЙКИ PG_STAT_STATEMENTS
# =============================================

# ОБЯЗАТЕЛЬНАЯ НАСТРОККА - загружает расширение при старте сервера
shared_preload_libraries = 'pg_stat_statements'


pg_stat_statements.max = 10000                       # МАКСИМАЛЬНОЕ КОЛИЧЕСТВО ОТСЛЕЖИВАЕМЫХ ЗАПРОСОВ
pg_stat_statements.track = all                       # КАКИЕ ЗАПРОСЫ ОТСЛЕЖИВАТЬ (top | all | none)
pg_stat_statements.track_planning = on               # ОТСЛЕЖИВАТЬ ЗАПРОСЫ ПЛАНИРОВЩИКА
pg_stat_statements.track_utility = on                # СБОР СТАТИСТИКИ ПО СЛУЖЕБНЫМ ЗАПРОСАМ
pg_stat_statements.track_io_timing = on              # СБОР СТАТИСТИКИ ПО БЛОКАМ ВВОДА/ВЫВОДА
pg_stat_statements.save = on                         # СОХРАНЕНИЕ СТАТИСТИКИ ПРИ ПЕРЕЗАГРУЗКЕ СЕРВЕРА 

# ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ДЛЯ СТАТИСТИКИ
track_io_timing = on
EOF

# Устанавливаем правильные права
chown postgres:postgres $STATS_CONF_FILE
chmod 644 $STATS_CONF_FILE

echo "Файл конфигурации создан: $STATS_CONF_FILE"

# Проверяем, есть ли include_dir в основном конфиге
if ! grep -q "include_dir" $CONF_FILE; then
    echo "Добавляем include_dir в основной конфиг..."
    echo "include_dir = 'conf.d'" >> $CONF_FILE
fi

# Перезапускаем PostgreSQL для применения настроек (ОБЯЗАТЕЛЬНО для shared_preload_libraries)
echo "Перезапускаем PostgreSQL для применения настроек..."
systemctl restart postgresql@18-main

# Ждем запуска
sleep 5

# Проверяем статус
echo "Проверяем статус PostgreSQL..."
systemctl status postgresql@18-main --no-pager

# Проверяем новые настройки
echo "Новые настройки pg_stat_statements:"
sudo -u postgres psql -c "SHOW shared_preload_libraries;"
sudo -u postgres psql -c "SHOW pg_stat_statements.max;"
sudo -u postgres psql -c "SHOW pg_stat_statements.track;"

echo "=== Настройка pg_stat_statements завершена ==="