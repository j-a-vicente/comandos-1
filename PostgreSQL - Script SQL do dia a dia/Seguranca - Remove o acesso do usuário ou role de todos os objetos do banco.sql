/************************************************************************************************************
												REMOVE TODOS OS ACESSOS
************************************************************************************************************/

DO 
$$
-- Paramentros: 
DECLARE 
	nmRole varchar := 'rl_dev_stg1g01'; 
	vrBase VARCHAR := 'stg1g01'; 
    query text; 
	B RECORD;
BEGIN
/* Verifica se a regra ou o usuários. */	
	IF (EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = nmRole )) 
		OR 
	   (EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = nmRole )) THEN
	
-- Base de dados. 
		query = 'REVOKE ALL ON DATABASE '|| vrBase ||' FROM '|| nmRole ||';';
		EXECUTE query;

		query = 'ALTER DEFAULT PRIVILEGES FOR ROLE postgres
		REVOKE ALL ON TABLES FROM '|| nmRole ||'; ';
		EXECUTE query; 	

-- Schema
		FOR B IN select schema_name from information_schema.schemata
					where schema_name not like 'information_schema'
					  and schema_name not like 'pg%'

		LOOP
	
			query = 'REVOKE ALL ON SCHEMA '|| B.schema_name ||' FROM  '|| nmRole ||'; 
	                 
					 ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
	                 REVOKE ALL ON TABLES FROM '|| nmRole ||'; 		

					 ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
					 REVOKE ALL  ON SEQUENCES FROM '|| nmRole ||'; 

					 ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA '|| B.schema_name ||'
					 REVOKE ALL ON FUNCTIONS FROM '|| nmRole ||'; ';
			 EXECUTE query;					
		END LOOP;
		
-- Tabelas
		FOR B IN SELECT table_schema, table_name FROM information_schema.tables 
				   WHERE table_schema not like 'information_schema'
					 and table_schema not like 'pg%'
		LOOP
		             
			query = 'REVOKE ALL ON TABLE ' || B.table_schema ||'.'||B.table_name ||' FROM '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;	


--	View
		FOR B IN SELECT table_schema, table_name FROM information_schema.views 
				   WHERE table_schema not like 'information_schema'
					 and table_schema not like 'pg%'
		LOOP
			query = 'REVOKE ALL ON TABLE ' || B.table_schema ||'.'||B.table_name ||' FROM '|| nmRole ||';';
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
			query = 'REVOKE ALL ON FUNCTION ' || B.nspname ||'.'||B.proname ||'('||pg_get_function_arguments(B.oid) ||') FROM '|| nmRole ||';';
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
			query = 'REVOKE ALL ON PROCEDURE ' || B.nspname ||'.'||B.proname ||'('||pg_get_function_arguments(B.oid) ||') FROM '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

-- SEQUENCE
		FOR B IN SELECT sequence_schema,sequence_name FROM information_schema.sequences 
				   WHERE sequence_schema not like 'information_schema'
					 and sequence_schema not like 'pg%'
		LOOP
			query = 'REVOKE ALL ON SEQUENCE ' ||B.sequence_schema ||'.'||B.sequence_name ||' FROM '|| nmRole ||';';
			--RAISE NOTICE '%', query; 
			EXECUTE query;

		END LOOP;

-- Outros acesso.
		query = 'REVOKE ALL ON TABLE schema_version FROM '|| nmRole ||';';
		EXECUTE query;

	ELSE 
	
	RAISE NOTICE 'A ROLE ou Usuário não existe.';
	
	END IF;		

END;
$$;	