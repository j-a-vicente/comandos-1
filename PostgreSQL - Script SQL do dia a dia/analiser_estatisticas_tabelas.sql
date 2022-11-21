
-- 1. Verificar o número de acesso sequencial e indexado à tabela fornece uma boa dica se a tabela está em uso ou obsoleta. A instrução select a seguir recupera as tabelas que podem ser obsoletas.
Select relname 
from pg_stat_user_tables
WHERE (idx_tup_fetch + seq_tup_read)= 0;

-- 2. Tabelas vazias podem ser recuperadas verificando o número de tupes ativos, ou seja, 
Select relname em 
pg_stat_user_tables 
WHERE n_live_tup = 0; 

-- 4. use pg_constraints para determinar as tabelas que dependem das tabelas acima 


-- 5. tabelas duplicadas, ou seja, a tabela pode ser encontrada em mais de um esquema
SELECT n.nspname as "Schema"
     , c.relname as "Name" 
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname IN (SELECT relname 
                     FROM pg_catalog.pg_class
                      WHERE relkind IN ('r')
					 GROUP BY relname
                     Having count(relname) > 1)
ORDER BY 2,1;

-- 6. Identifique índices não utilizados.
SELECT
    idstat.relname AS TABLE_NAME,
    indexrelname AS index_name,
    idstat.idx_scan AS index_scans_count,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    tabstat.idx_scan AS table_reads_index_count,
    tabstat.seq_scan AS table_reads_seq_count,
    tabstat.seq_scan + tabstat.idx_scan AS table_reads_count,
    n_tup_upd + n_tup_ins + n_tup_del AS table_writes_count,
    pg_size_pretty(pg_relation_size(idstat.relid)) AS table_size
FROM
    pg_stat_user_indexes AS idstat
JOIN
    pg_indexes
    ON
    indexrelname = indexname
    AND
    idstat.schemaname = pg_indexes.schemaname
JOIN
    pg_stat_user_tables AS tabstat
    ON
    idstat.relid = tabstat.relid
WHERE
    indexdef !~* 'unique'
ORDER BY
    idstat.idx_scan DESC,
    pg_relation_size(indexrelid) DESC
	
	
select relname, n_live_tup, n_dead_tup
from pg_stat_user_tables
group by 1, 2, 3
order by 2, 3 desc	