SELECT ROUND(user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ),2) AS [index_advantage] 
     , migs.last_user_seek 
     , mid.[statement] AS [Database.Schema.Table] 
     , mid.equality_columns 
     , mid.inequality_columns 
     , mid.included_columns 
     , migs.unique_compiles 
     , migs.user_seeks 
     , ROUND(migs.avg_total_user_cost,2) AS 'avg_total_user_cost'
     , migs.avg_user_impact 
     ,'CREATE INDEX missing_index_' + 
        CONVERT (varchar, mig.index_group_handle) + '_' + 
        CONVERT (varchar, mid.index_handle) + ' ON ' + 
        mid.statement + ' (' + ISNULL (mid.equality_columns, '') + 
        CASE
            WHEN mid.equality_columns IS NOT NULL
            AND mid.inequality_columns IS NOT NULL THEN ','
            ELSE ''
        END + ISNULL (mid.inequality_columns, '') + ')' + 
        ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement     
FROM sys.dm_db_missing_index_group_stats AS migs WITH ( NOLOCK )  
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH ( NOLOCK ) ON migs.group_handle = mig.index_group_handle  
INNER JOIN sys.dm_db_missing_index_details AS mid WITH ( NOLOCK ) ON mig.index_handle = mid.index_handle 
WHERE mid.database_id = DB_ID() 
ORDER BY index_advantage DESC ; 

