#!/bin/bash
# monitor-pg-json-logs.sh

LOG_DIR="/var/lib/postgresql/18/main/log"
CURRENT_JSON_LOG=$(ls -t $LOG_DIR/postgresql-*.json.log 2>/dev/null | head -1)

if [ -z "$CURRENT_JSON_LOG" ]; then
    echo "JSON логи не найдены"
    exit 1
fi

echo "Мониторинг JSON логов PostgreSQL"
echo "Файл: $CURRENT_JSON_LOG"
echo "=============================="
echo "1 - Сырые JSON логи"
echo "2 - Форматированные JSON логи (требует jq)"
echo "3 - Только SQL запросы"
echo "4 - Только ошибки"
echo "=============================="

read -p "Выберите вариант [1-4]: " choice

case $choice in
    1)
        echo "Сырые JSON логи (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_JSON_LOG"
        ;;
    2)
        if command -v jq &> /dev/null; then
            echo "Форматированные JSON логи (Ctrl+C для выхода):"
            sudo tail -f "$CURRENT_JSON_LOG" | jq '.'
        else
            echo "jq не установлен. Установите: sudo apt install jq"
        fi
        ;;
    3)
        echo "Только SQL запросы (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_JSON_LOG" | grep --line-buffered '"statement"'
        ;;
    4)
        echo "Только ошибки (Ctrl+C для выхода):"
        sudo tail -f "$CURRENT_JSON_LOG" | grep --line-buffered -E '"ERROR|"FATAL|"PANIC'
        ;;
    *)
        echo "Неверный выбор"
        ;;
esac