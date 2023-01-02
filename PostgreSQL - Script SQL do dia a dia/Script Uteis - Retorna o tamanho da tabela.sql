	 
SELECT esquema, tabela, pg_size_pretty(pg_relation_size(esq_tab)) AS tamanho
     , pg_size_pretty(pg_total_relation_size(esq_tab)) AS tamanho_total
FROM (SELECT tablename AS tabela, schemaname AS esquema, schemaname||'.'||tablename AS esq_tab
       FROM pg_catalog.pg_tables 
	   WHERE schemaname NOT IN('pg_catalog','information_schema','pg_toast')) AS x 
ORDER BY pg_relation_size(esq_tab) DESC	 


select t.table_catalog
     , t.table_schema
     , t.table_name
     , (pg_relation_size('"'||t.table_schema||'"."'||t.table_name||'"')) as "table_size"
     , (pg_indexes_size('"'||t.table_schema||'"."'||t.table_name||'"')) as "index_size"
	 , ((pg_relation_size('"'||t.table_schema||'"."'||t.table_name||'"')) + (pg_indexes_size('"'||t.table_schema||'"."'||t.table_name||'"')) * 8 ) / 1024 /1024 /1024
     , (SELECT cast(reltuples as int) AS estimate FROM pg_class WHERE relname = t.table_name) as "table_row"
from information_schema.tables as t
where t.table_schema in('acl','client','criminal','extrator','jt','prublic')
  --and t.table_type = 'BASE TABLE'
order by t.table_catalog
     , t.table_schema, t.table_name