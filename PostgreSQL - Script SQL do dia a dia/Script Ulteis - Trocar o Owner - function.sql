DO 
$$
DECLARE 
	B RECORD;
	query text;
BEGIN
	FOR B IN SELECT n.nspname,p.proname, p.oid FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
	WHERE n.nspname = 'public'
	  AND pg_catalog.pg_get_function_arguments(p.oid) NOT LIKE '%DEFAULT%'
	
	LOOP
		query = 'ALTER FUNCTION ' || B.nspname ||'.'||B.proname ||'('||pg_get_function_arguments(B.oid) ||') OWNER TO mapasculturaisdev;';
		--RAISE NOTICE '%', query; 
		EXECUTE query;
					
	END LOOP;
END;
$$;/