DO
$$
BEGIN
   -- RAISE NOTICE '%', (  -- use instead of EXECUTE to see generated commands
   EXECUTE (
   SELECT string_agg(format('GRANT ALL ON SCHEMA %I TO roledesenvolvedor', nspname), '; ')
   FROM   pg_namespace
   WHERE  nspname <> 'information_schema' -- exclude information schema and ...
   AND    nspname NOT LIKE 'pg\_%'        -- ... system schemas
   );
END
$$;