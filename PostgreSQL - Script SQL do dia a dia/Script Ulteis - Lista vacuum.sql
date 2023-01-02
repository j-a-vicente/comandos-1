SELECT *
FROM pg_stat_user_tables
WHERE relname LIKE '%lock%'
ORDER BY n_dead_tup DESC

VACUUM (VERBOSE, ANALYZE) "jbpm_byteblock"

VACUUM ANALYZE "jbpm_byteblock"

select * from pg_stat_progress_vacuum

select relname, last_autoanalyze, last_autovacuum, last_vacuum, n_dead_tup 
from pg_stat_all_tables 
where n_dead_tup >0
order by n_dead_tup desc

select pg_database_size('h5_pje');

SELECT
    pg_size_pretty (
        pg_database_size ('h5_pje')
    );