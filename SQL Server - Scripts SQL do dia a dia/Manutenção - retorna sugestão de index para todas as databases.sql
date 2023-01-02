CREATE TABLE  #IndexTable(  
		index_advantage FLOAT NULL,
		last_user_seek DATETIME NULL,
		[Database_Schema_Table] NVARCHAR(255) NULL,
		equality_columns NVARCHAR(255) NULL,
		inequality_columns NVARCHAR(255) NULL,
		included_columns NVARCHAR(255) NULL,
		unique_compiles INT NULL,
		user_seeks INT NULL,
		avg_total_user_cost FLOAT NULL,
		avg_user_impact FLOAT NULL,
		create_index_statement NVARCHAR(MAX) NULL
		)  

DECLARE @dbname sysname
DECLARE @ScriptCMD nchar(3000)
DECLARE db_for CURSOR FOR

	SELECT name
		FROM sys.sysdatabases
	WHERE dbid > 4
	ORDER BY name DESC



OPEN db_for 
	FETCH NEXT FROM db_for INTO @dbname
		WHILE @@FETCH_STATUS = 0
		BEGIN

		SET @ScriptCMD = 'USE ['+ @dbname  +']

			INSERT INTO #IndexTable  
						(index_advantage,
						 last_user_seek,
		                 [Database_Schema_Table],
		                 equality_columns,
		                 inequality_columns,
		                 included_columns,
		                 unique_compiles,
		                 user_seeks,
		                 avg_total_user_cost,
		                 avg_user_impact,
		                 create_index_statement)			
			SELECT ROUND(user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ),2) AS [index_advantage] 
					 , migs.last_user_seek 
					 , mid.[statement] AS [Database.Schema.Table] 
					 , mid.equality_columns 
					 , mid.inequality_columns 
					 , mid.included_columns 
					 , migs.unique_compiles 
					 , migs.user_seeks 
					 , ROUND(migs.avg_total_user_cost,2) AS ''avg_total_user_cost''
					 , migs.avg_user_impact 
					 ,''CREATE INDEX missing_index_'' + 
						CONVERT (varchar, mig.index_group_handle) + ''_'' + 
						CONVERT (varchar, mid.index_handle) + '' ON '' + 
						mid.statement + '' ('' + ISNULL (mid.equality_columns, '''') + 
						CASE
							WHEN mid.equality_columns IS NOT NULL
							AND mid.inequality_columns IS NOT NULL THEN '',''
							ELSE ''''
						END + ISNULL (mid.inequality_columns, '''') + '')'' + 
						ISNULL ('' INCLUDE ('' + mid.included_columns + '')'', '''') AS create_index_statement     
				FROM sys.dm_db_missing_index_group_stats AS migs WITH ( NOLOCK )  
				INNER JOIN sys.dm_db_missing_index_groups AS mig WITH ( NOLOCK ) ON migs.group_handle = mig.index_group_handle  
				INNER JOIN sys.dm_db_missing_index_details AS mid WITH ( NOLOCK ) ON mig.index_handle = mid.index_handle 
				WHERE mid.database_id = DB_ID() 
				  --AND avg_user_impact >= 90 
				ORDER BY index_advantage DESC ;  '

				exec sp_executesql  @ScriptCMD

	FETCH NEXT FROM db_for INTO @dbname
	END

CLOSE db_for
DEALLOCATE db_for

SELECT * FROM #IndexTable

DROP TABLE #IndexTable
