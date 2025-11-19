#!/bin/bash
# monitor-pg-logs-advanced.sh

# Определяем путь к логам
if [ -d "/var/lib/postgresql/18/main/log" ] && [ "$(ls -A /var/lib/postgresql/18/main/log/*.log 2>/dev/null)" ]; then
    LOG_DIR="/var/lib/postgresql/18/main/log"
elif [ -d "/var/log/postgresql" ] && [ "$(ls -A /var/log/postgresql/*.log 2>/dev/null)" ]; then
    LOG_DIR="/var/log/postgresql"
else
    echo "Логи PostgreSQL не найдены!"
    echo "Проверьте директории:"
    echo "/var/lib/postgresql/18/main/log/"
    echo "/var/log/postgresql/"
    exit 1
fi

CURRENT_LOG=$(ls -t $LOG_DIR/postgresql-*.log 2>/dev/null | head -1)

if [ -z "$CURRENT_LOG" ]; then
    echo "Файлы логов не найдены в $LOG_DIR"
    exit 1
fi

echo "Мониторинг логов PostgreSQL"
echo "Директория: $LOG_DIR"
echo "Текущий файл: $CURRENT_LOG"
echo "=============================="
echo "1 - Все логи"
echo "2 - Только SQL запросы"
echo "3 - Только подключения"
echo "4 - Только ошибки"
echo "5 - Только медленные запросы"
echo "6 - Фильтр по базе данных"
echo "=============================="

# Получаем список баз данных для подсказки
echo "Доступные базы данных:"
sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" 2>/dev/null | while read db; do
    if [ -n "$db" ]; then
        echo "  - $db"
    fi
done

echo "=============================="

read -p "Выберите вариант [1-6]: " choice

case $choice in
    1)
        echo "Просмотр всех логов (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_LOG"
        ;;
    2)
        echo "Только SQL запросы (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_LOG" | grep --line-buffered "statement:"
        ;;
    3)
        echo "Только подключения (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_LOG" | grep --line-buffered -E "(connection|disconnection)"
        ;;
    4)
        echo "Только ошибки (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_LOG" | grep --line-buffered -E "(ERROR|FATAL|PANIC)"
        ;;
    5)
        echo "Только медленные запросы (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_LOG" | grep --line-buffered "duration:"
        ;;
    6)
        echo "Доступные базы данных:"
        DB_LIST=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;" 2>/dev/null)
        echo "$DB_LIST"
        read -p "Введите имя базы данных для фильтра: " db_filter
        if [ -n "$db_filter" ]; then
            echo "Фильтр по базе данных: $db_filter (Ctrl+C для выхода):"
            # Ищем по разным форматам, которые могут быть в логах
            sudo tail -f "$CURRENT_LOG" | grep --line-buffered -E "db=$db_filter|database=$db_filter"
        else
            echo "Имя базы данных не указано"
        fi
        ;;
    *)
        echo "Неверный выбор"
        ;;
esac