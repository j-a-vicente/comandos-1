/************************************************************************************************************
												ACESSO TOTAL
************************************************************************************************************/
DO 
$$
-- Paramentros: 
DECLARE 
	nmRole varchar := 'rl_dev_stg1g03'; 
	vrBase VARCHAR := 'stg1g01'; 
    query text; 
	B RECORD;
BEGIN

/* Criar a "ROLE" regra de acesso. */
	IF NOT EXISTS ( -- Se não existi criar a ROLE.
		SELECT FROM pg_catalog.pg_roles
		WHERE rolname = nmRole ) THEN
		
			query = 'CREATE ROLE '|| nmRole ||' WITH 
			NOLOGIN 
			NOSUPERUSER 
			NOCREATEDB 
			NOCREATEROLE 
			INHERIT 
			NOREPLICATION 
			CONNECTION LIMIT -1;' ;
			EXECUTE query; 
			
			query = 'GRANT rs_pje_gerente, rs_pje_tjrj_dml TO '|| nmRole ||';';	
			
			EXECUTE query;		
	ELSE	
	
	RAISE NOTICE 'A ROLE já existi.';
	
	END IF;
	
/* Se a regra existi iniciar a adinção dos acessos. */	
	IF EXISTS (
		SELECT FROM pg_catalog.pg_roles
		WHERE rolname = nmRole ) THEN

	-- Base de dados. 
		query = 'GRANT ALL ON DATABASE '|| vrBase ||' TO '|| nmRole ||';';
			EXECUTE query; 

		query = 'ALTER DEFAULT PRIVILEGES FOR ROLE postgres
		GRANT ALL ON TABLES TO '|| nmRole ||'; ';
			EXECUTE query; 

	-- Schema.
		FOR B IN select schema_name from information_schema.schemata
					where schema_name not like 'information_schema'
					  and schema_name not like 'pg%'

		LOOP
			query = 'GRANT ALL ON SCHEMA '|| B.schema_name ||' TO  '|| nmRole ||'; 
	ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
	GRANT ALL ON TABLES TO '|| nmRole ||'; 

	ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
	GRANT USAGE  ON SEQUENCES TO '|| nmRole ||'; 

	ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
	GRANT ALL ON FUNCTIONS TO '|| nmRole ||'; ';
			--RAISE NOTICE '%', query; 
			EXECUTE query;					
		END LOOP;

	-- Tabelas
		FOR B IN SELECT table_schema, table_name FROM information_schema.tables 
				   WHERE table_schema not like 'information_schema'
					 and table_schema not like 'pg%'
		LOOP
			query = 'GRANT ALL ON TABLE ' || B.table_schema ||'.'||B.table_name ||' TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

	--	View
		FOR B IN SELECT table_schema, table_name FROM information_schema.views 
				   WHERE table_schema not like 'information_schema'
					 and table_schema not like 'pg%'
		LOOP
			query = 'GRANT ALL ON TABLE ' || B.table_schema ||'.'||B.table_name ||' TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

	-- Function
		FOR B IN SELECT n.nspname,p.proname, p.oid FROM pg_catalog.pg_proc p
			LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
				   WHERE n.nspname not like 'information_schema'
					 AND n.nspname not like 'pg%'	
					 AND pg_catalog.pg_get_function_arguments(p.oid) NOT LIKE '%DEFAULT%'
					 AND P.Prokind = 'f'
		LOOP
			query = 'GRANT ALL ON FUNCTION ' || B.nspname ||'.'||B.proname ||'('||pg_get_function_arguments(B.oid) ||') TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

	-- Procedure
		FOR B IN SELECT n.nspname,p.proname, p.oid FROM pg_catalog.pg_proc p
			LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
				   WHERE n.nspname not like 'information_schema'
					 AND n.nspname not like 'pg%'	
					 AND pg_catalog.pg_get_function_arguments(p.oid) NOT LIKE '%DEFAULT%'
					 AND P.Prokind = 'p'
		LOOP
			query = 'GRANT ALL ON PROCEDURE ' || B.nspname ||'.'||B.proname ||'('||pg_get_function_arguments(B.oid) ||') TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

	-- SEQUENCE
		FOR B IN SELECT sequence_schema,sequence_name FROM information_schema.sequences 
				   WHERE sequence_schema not like 'information_schema'
					 and sequence_schema not like 'pg%'
		LOOP
			query = 'GRANT ALL ON SEQUENCE ' ||B.sequence_schema ||'.'||B.sequence_name ||' TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;
	-- materialized 
		FOR B IN SELECT schemaname, matviewname from pg_matviews

		LOOP
			query = 'GRANT ALL ON TABLE ' || B.schemaname ||'.'||B.matviewname ||' TO '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;
	-- Outros acesso.
		query = 'GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE schema_version TO '|| nmRole ||';';
		EXECUTE query;		
		
	ELSE	
	
	RAISE NOTICE 'A ROLE não foi criada.';
	
	END IF;		
	
END;
$$;	