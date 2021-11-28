DO 
$$
DECLARE 
	B RECORD;
	S RECORD;
	query text;
BEGIN
-- Loop 01 - Lista todas as databases;
	FOR B IN SELECT datname	  FROM   pg_catalog.pg_database WHERE datname NOT LIKE 'template%'
	LOOP
		--Conta o comando para a database e executa a query
		query = 'GRANT ALL ON DATABASE '|| B.datname ||' TO roledesenvolvedor;';		
		EXECUTE query;
					
	END LOOP;
END;
$$;