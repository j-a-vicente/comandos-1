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