SELECT
	 table_name,
	 pg_size_pretty(table_size)   || ' (' || CASE WHEN total_size = 0 THEN 0.00 ELSE round(table_size * 100 / total_size) END   || ' %)' AS table_size,
	 pg_size_pretty(indexes_size) || ' (' || CASE WHEN total_size = 0 THEN 0.00 ELSE round(indexes_size * 100 / total_size) END || ' %)' AS indexes_size,
	 pg_size_pretty(total_size)                                                                                                          AS total_size
FROM (
	(SELECT
		table_name,
		pg_table_size(table_name)          AS table_size,
		pg_indexes_size(table_name)        AS indexes_size,
		pg_total_relation_size(table_name) AS total_size
	FROM (
		SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
		FROM information_schema.tables
		WHERE NOT table_schema IN ('pg_catalog', 'information_schema')
	) AS all_tables
	ORDER BY total_size DESC)

	UNION ALL

	(SELECT
		'TOTAL',
		sum(pg_table_size(table_name))          AS table_size,
		sum(pg_indexes_size(table_name))        AS indexes_size,
		sum(pg_total_relation_size(table_name)) AS total_size
	FROM (
		SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
		FROM information_schema.tables
		WHERE NOT table_schema IN ('pg_catalog', 'information_schema')
	) AS all_tables)

) AS pretty_sizes;


-----------------------------------------------------------------------------------

select schemaname as table_schema,
       relname as table_name,
       pg_size_pretty(pg_total_relation_size(relid)) as total_size,
       pg_size_pretty(pg_relation_size(relid)) as data_size,
       pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) 
        as external_size
from pg_catalog.pg_statio_user_tables
order by pg_total_relation_size(relid) desc,
         pg_relation_size(relid) desc;


--------------------------------------------------------------------------------------

select pg_indexes_size('table_name');
SELECT pg_indexes_size('film');
SELECT pg_size_pretty (pg_indexes_size('film'));

--------------------------------------------------------------------------------------

SELECT esquema, tabela,
       pg_size_pretty(pg_relation_size(esq_tab)) AS tamanho,
       pg_size_pretty(pg_total_relation_size(esq_tab)) AS tamanho_total
  FROM (SELECT tablename AS tabela,
               schemaname AS esquema,
               schemaname||'.'||tablename AS esq_tab
          FROM pg_catalog.pg_tables
         WHERE schemaname NOT
            IN ('pg_catalog', 'information_schema', 'pg_toast') ) AS x
 ORDER BY pg_total_relation_size(esq_tab) DESC;


 