-- Altera o nome da base 
-- Lista todos os processo da base de dados e mata os processos

-- Lista os processos e mata eles
DO 
$$
DECLARE 
	B RECORD;
	query text;
BEGIN
	FOR B IN select * from pg_stat_activity WHERE datname = 'pje_02032023'
	LOOP
		query = 'select pg_terminate_backend(' ||B.pid ||');';
		--RAISE NOTICE '%', query; 
		EXECUTE query;
					
	END LOOP;
END;
$$;

-- Altera o nome da base
ALTER DATABASE pje_02032023 RENAME TO "TR01";