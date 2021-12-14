DO 
$$
DECLARE 
	B RECORD;
	query text;
BEGIN
	FOR B IN SELECT table_schema, table_name FROM information_schema.views WHERE table_schema not in ('pg_catalog', 'information_schema')
	
	LOOP
		query = 'ALTER TABLE ' || B.table_schema ||'.'||B.table_name ||' OWNER TO mapasculturaisdev;';
		--RAISE NOTICE '%', query; 
		EXECUTE query;
					
	END LOOP;
END;
$$;