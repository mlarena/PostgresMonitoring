#!/bin/bash
# check-pg-stat-statements.sh

set -e

echo "=== Проверка работы pg_stat_statements ==="

# Проверяем работу расширения
echo "Проверяем работу pg_stat_statements..."
sudo -u postgres psql -c "
SELECT 
    count(*) as queries_tracked,
    pg_size_pretty(pg_total_relation_size('pg_stat_statements')) as stats_size
FROM pg_stat_statements;" 2>/dev/null || echo "Расширение еще не готово, подождите несколько минут"

echo "=== Проверка завершена ==="