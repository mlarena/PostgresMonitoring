#!/bin/bash
# pg_stat_monitor.sh

echo "=== Мониторинг pg_stat_statements ==="

sudo -u postgres psql -c "
-- Топ-10 самых медленных запросов
SELECT '=== ТОП-10 САМЫХ МЕДЛЕННЫХ ЗАПРОСОВ ===';
SELECT 
    left(query, 100) as short_query,
    calls,
    round(total_time::numeric, 2) as total_time_ms,
    round(mean_time::numeric, 2) as mean_time_ms,
    round((100 * total_time / sum(total_time) over ())::numeric, 2) as percentage
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

-- Топ-10 самых частых запросов
SELECT '=== ТОП-10 САМЫХ ЧАСТЫХ ЗАПРОСОВ ===';
SELECT 
    left(query, 100) as short_query,
    calls,
    round(total_time::numeric, 2) as total_time_ms,
    round(mean_time::numeric, 2) as mean_time_ms
FROM pg_stat_statements 
ORDER BY calls DESC 
LIMIT 10;

-- Запросы с наибольшим I/O
SELECT '=== ЗАПРОСЫ С НАИБОЛЬШИМ I/O ===';
SELECT 
    left(query, 100) as short_query,
    calls,
    shared_blks_read,
    shared_blks_written,
    round(total_time::numeric, 2) as total_time_ms
FROM pg_stat_statements 
WHERE shared_blks_read + shared_blks_written > 0
ORDER BY shared_blks_read + shared_blks_written DESC 
LIMIT 10;
" 2>/dev/null || echo "Не удалось выполнить запросы к pg_stat_statements"