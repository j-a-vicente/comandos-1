--Alternativa Simplificada (usando views específicas do Synapse):
SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    SUM(p.rows) AS RowCounts
FROM 
    sys.tables t
INNER JOIN 
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE 
    t.is_ms_shipped = 0
GROUP BY 
    t.schema_id, t.name, i.name, i.type_desc
ORDER BY 
    SchemaName, TableName, IndexName;


--Para obter informações de tamanho no Synapse SQL Pool:
SELECT 
    tp.name AS TableName,
    SUM(pd.used_page_count * 8 / 1024) AS SizeMB
FROM 
    sys.tables tp
INNER JOIN 
    sys.indexes ind ON tp.object_id = ind.object_id
INNER JOIN 
    sys.partitions part ON ind.object_id = part.object_id AND ind.index_id = part.index_id
INNER JOIN 
    sys.dm_pdw_nodes_db_partition_stats pd ON part.partition_id = pd.partition_id
GROUP BY 
    tp.name
ORDER BY 
    SizeMB DESC;    