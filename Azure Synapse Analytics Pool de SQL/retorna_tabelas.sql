SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.NAME AS TableName,
    SUM(p.rows) AS RowCounts
FROM 
    sys.tables t
INNER JOIN 
    sys.partitions p ON t.object_id = p.object_id
WHERE 
    p.index_id IN (0, 1)
GROUP BY 
    t.schema_id, t.NAME
ORDER BY 
    RowCounts DESC;