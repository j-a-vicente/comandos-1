SELECT 
     sysobjects.name AS trigger_name 
    ,USER_NAME(sysobjects.uid) AS trigger_owner 
    ,s.name AS table_schema 
    ,OBJECT_NAME(parent_obj) AS table_name 
    ,OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS isupdate 
    ,OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') AS isdelete 
    ,OBJECTPROPERTY( id, 'ExecIsInsertTrigger') AS isinsert 
    ,OBJECTPROPERTY( id, 'ExecIsAfterTrigger') AS isafter 
    ,OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') AS isinsteadof 
    ,OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') AS [disabled] 
FROM sysobjects 

INNER JOIN sysusers 
    ON sysobjects.uid = sysusers.uid 

INNER JOIN sys.tables t 
    ON sysobjects.parent_obj = t.object_id 

INNER JOIN sys.schemas s 
    ON t.schema_id = s.schema_id 

WHERE sysobjects.type = 'TR' 

-----------------------------------------------------------------------
SELECT 
	t2.[name] TableTriggerReference
	, SCHEMA_NAME(t2.[schema_id]) TableSchemaName
	, t3.[rowcnt] TableReferenceRowCount
	, t1.[name] TriggerName
FROM sys.triggers t1
	INNER JOIN sys.tables t2 ON t2.object_id = t1.parent_id
	INNER JOIN sys.sysindexes t3 On t2.object_id = t3.id
WHERE t1.is_disabled = 0
	AND t1.is_ms_shipped = 0
	AND t1.parent_class = 1

-----------------------------------------------------------------------
SELECT 
	t2.[name] TableTriggerReference
	, SCHEMA_NAME(t2.[schema_id]) TableSchemaName
	, t3.[rowcnt] TableReferenceRowCount
	, t1.[name] TriggerName
	, 'ALTER TABLE ' + SCHEMA_NAME(t2.schema_id) + '.' + t2.[name] + ' DISABLE TRIGGER ' + t1.[name] Script
FROM sys.triggers t1
	INNER JOIN sys.tables t2 ON t2.object_id = t1.parent_id
	INNER JOIN sys.sysindexes t3 On t2.object_id = t3.id
WHERE t1.is_disabled = 0
	AND t1.is_ms_shipped = 0
	AND t1.parent_class = 1