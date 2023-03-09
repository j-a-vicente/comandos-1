







--Lista as Sequences
SELECT 
  sequences.sequence_catalog, 
  sequences.sequence_schema, 
  sequences.sequence_name
FROM 
  information_schema.sequences;


--Lista as Tables e Views
SELECT 
  tables.table_catalog, 
  tables.table_schema, 
  tables.table_name, 
  tables.table_type
FROM 
  information_schema.tables;

--Lista as Triggers 
SELECT 
  triggers.trigger_catalog, 
  triggers.trigger_schema, 
  triggers.trigger_name, 
  triggers.event_manipulation
FROM 
  information_schema.triggers;

  --Listas as Functions
select n.nspname as function_schema,
       p.proname as function_name
from pg_proc p
left join pg_namespace n on p.pronamespace = n.oid
where n.nspname not in ('pg_catalog', 'information_schema')
order by function_schema,
         function_name;



ALTER FUNCTION public._add_overview_constraint(name, name, name, name, name, name, integer) OWNER TO mapasculturaisdev;

"CREATE OR REPLACE FUNCTION public._add_overview_constraint(ovschema name, ovtable name, ovcolumn name, refschema name, reftable name, refcolumn name, factor integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		fqtn text;
		cn name;
 (...)"

 
/*
   EXECUTE (
   SELECT string_agg(format('ALTER FUNCTION %I.%I(%I) OWNER TO mapasculturaisdev ', n.nspname,p.proname,pg_get_function_arguments(p.oid)), '; ')
    FROM pg_proc p
     LEFT JOIN pg_namespace n on p.pronamespace = n.oid
     LEFT JOIN pg_language l on p.prolang = l.oid
     LEFT JOIN pg_type t on t.oid = p.prorettype 
    WHERE n.nspname not in ('pg_catalog', 'information_schema')
      AND t.typname <> 'trigger'
   );*/


ALTER FUNCTION public._postgis_selectivity(regclass, text, geometry, text)
  OWNER TO mapasculturaisdev;


---------------------------------------------------