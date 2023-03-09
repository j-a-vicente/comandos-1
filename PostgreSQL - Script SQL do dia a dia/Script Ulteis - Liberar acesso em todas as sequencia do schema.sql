DO 
$$
DECLARE 
	B RECORD;
	query text;
BEGIN
	FOR B IN SELECT sequence_schema,sequence_name FROM information_schema.sequences WHERE sequence_schema = 'tjrj'
	LOOP
		query = 'GRANT ALL ON SEQUENCE ' ||B.sequence_schema ||'.'||B.sequence_name ||' TO  tjrj_dml;';
		--RAISE NOTICE '%', query; 
		EXECUTE query;
					
	END LOOP;
END;
$$;