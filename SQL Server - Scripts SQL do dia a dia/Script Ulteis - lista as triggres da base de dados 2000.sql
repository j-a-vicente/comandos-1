SELECT 
     o.name AS trigger_name 
    ,'x' AS trigger_owner 
    /*USER_NAME(o.uid)*/ 
    ,s.name AS table_schema 
    ,OBJECT_NAME(o.parent_obj) AS table_name 
    ,OBJECTPROPERTY(o.id, 'ExecIsUpdateTrigger') AS isupdate 
    ,OBJECTPROPERTY(o.id, 'ExecIsDeleteTrigger') AS isdelete 
    ,OBJECTPROPERTY(o.id, 'ExecIsInsertTrigger') AS isinsert 
    ,OBJECTPROPERTY(o.id, 'ExecIsAfterTrigger') AS isafter 
    ,OBJECTPROPERTY(o.id, 'ExecIsInsteadOfTrigger') AS isinsteadof 
    ,OBJECTPROPERTY(o.id, 'ExecIsTriggerDisabled') AS [disabled] 
FROM sysobjects AS o 
/*
INNER JOIN sysusers 
    ON sysobjects.uid = sysusers.uid 
*/  
INNER JOIN sysobjects AS o2 
    ON o.parent_obj = o2.id 

INNER JOIN sysusers AS s 
    ON o2.uid = s.uid 

WHERE o.type = 'TR'