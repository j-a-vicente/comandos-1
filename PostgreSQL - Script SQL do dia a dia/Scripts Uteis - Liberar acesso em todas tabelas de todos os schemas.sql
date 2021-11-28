DO
$$
BEGIN
   -- RAISE NOTICE '%', (  -- use instead of EXECUTE to see generated commands
   EXECUTE (
   SELECT string_agg(format('GRANT ALL ON TABLE %I.%I  TO roledesenvolvedor ', table_schema,table_name), '; ')
   FROM information_schema.tables
   where table_schema <> 'pg_catalog'
	 and table_schema <> 'information_schema'
	 and table_name not like 'pg_%'        -- ... system schemas
   );
END
$$;