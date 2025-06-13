SELECT 
    SCHEMA_NAME(p.schema_id) AS schema_name,
    p.name AS procedure_name,
    p.create_date,
    p.modify_date,
    m.definition AS procedure_definition
FROM sys.procedures p
LEFT JOIN sys.sql_modules m ON p.object_id = m.object_id
ORDER BY schema_name, procedure_name;
