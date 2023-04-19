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


 ------------------------------------------------------------------------------------------

SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;


 ------------------------------------------------------------------------------------------


WITH RECURSIVE pg_inherit(inhrelid, inhparent) AS
    (select inhrelid, inhparent
    FROM pg_inherits
    UNION
    SELECT child.inhrelid, parent.inhparent
    FROM pg_inherit child, pg_inherits parent
    WHERE child.inhparent = parent.inhrelid),
pg_inherit_short AS (SELECT * FROM pg_inherit WHERE inhparent NOT IN (SELECT inhrelid FROM pg_inherit))
SELECT table_schema
    , TABLE_NAME
    , row_estimate
    , pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
    , total_bytes::float8 / sum(total_bytes) OVER () AS total_size_share
  FROM (
    SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
    FROM (
         SELECT c.oid
              , nspname AS table_schema
              , relname AS TABLE_NAME
              , CAST(SUM(c.reltuples) OVER (partition BY parent) AS INT) AS row_estimate
              , SUM(pg_total_relation_size(c.oid)) OVER (partition BY parent) AS total_bytes
              , SUM(pg_indexes_size(c.oid)) OVER (partition BY parent) AS index_bytes
              , SUM(pg_total_relation_size(reltoastrelid)) OVER (partition BY parent) AS toast_bytes
              , parent
          FROM (
                SELECT pg_class.oid
                    , reltuples
                    , relname
                    , relnamespace
                    , pg_class.reltoastrelid
                    , COALESCE(inhparent, pg_class.oid) parent
                FROM pg_class
                    LEFT JOIN pg_inherit_short ON inhrelid = oid
                WHERE relkind IN ('r', 'p')
             ) c
             LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  ) a
  WHERE oid = parent
) a
ORDER BY 1,2;

 ------------------------------------------------------------------------------------------

WITH RECURSIVE pg_inherit(inhrelid, inhparent) AS
    (select inhrelid, inhparent
    FROM pg_inherits
    UNION
    SELECT child.inhrelid, parent.inhparent
    FROM pg_inherit child, pg_inherits parent
    WHERE child.inhparent = parent.inhrelid),
pg_inherit_short AS (SELECT * FROM pg_inherit WHERE inhparent NOT IN (SELECT inhrelid FROM pg_inherit))
SELECT parent::regclass
    , coalesce(spcname, 'default') pg_tablespace_name
    , row_estimate
    , pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
    , 100 * total_bytes::float8 / sum(total_bytes) OVER () AS PERCENT
  FROM (
    SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
    FROM (
         SELECT parent
              , reltablespace
              , SUM(c.reltuples) AS row_estimate
              , SUM(pg_total_relation_size(c.oid)) AS total_bytes
              , SUM(pg_indexes_size(c.oid)) AS index_bytes
              , SUM(pg_total_relation_size(reltoastrelid)) AS toast_bytes
          FROM (
                SELECT pg_class.oid
                    , reltuples
                    , relname
                    , relnamespace
                    , reltablespace reltablespace
                    , pg_class.reltoastrelid
                    , COALESCE(inhparent, pg_class.oid) parent
                FROM pg_class
                    LEFT JOIN pg_inherit_short ON inhrelid = oid
                WHERE relkind IN ('r', 'p')
             ) c
            GROUP BY parent, reltablespace
  ) a
) a LEFT JOIN pg_tablespace ON (pg_tablespace.oid = reltablespace)
ORDER BY total_bytes DESC;



/*******************************************************************************************************************************
Referència:
https://wiki.postgresql.org/wiki/Disk_Usage




















*******************************************************************************************************************************/






