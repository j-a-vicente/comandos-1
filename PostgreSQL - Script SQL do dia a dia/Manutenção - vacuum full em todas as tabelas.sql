/*
Este script cria o comando para o VACUUM FULL em todas as tabelas da base de dados.
*/

DO 
$$
DECLARE 
	B RECORD;
	query text;
BEGIN
	-- O select no loop lista todas as tabelas menos a dos schemas contido no WHERE  AND table_schema NOT IN('pg_catalog','information_schema')
	FOR B IN SELECT tables.table_schema, 
					tables.table_name
			 FROM information_schema.tables
	          WHERE table_type = 'BASE TABLE'
			    AND table_schema NOT IN('pg_catalog','information_schema')
				ORDER BY table_schema,tables.table_name
	LOOP
		query = 'VACUUM FULL '||B.table_schema||'.'||B.table_name||';';
	 -- Este comando printa na menssagem os script de vacuum para cada tabela
		RAISE NOTICE '%', query; 
		
	END LOOP;
END;
$$;	