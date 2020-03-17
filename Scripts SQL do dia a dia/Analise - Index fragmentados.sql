USE [master]
GO

/******* Criação das trabelas temporarias *********/

		CREATE TABLE  #IndexTable 
        (  
        [Database] sysname, [Table] sysname, [Index Name] sysname NULL, index_id smallint,  
        [object_id] INT, [Index Type] VARCHAR(20), [Alloc Unit Type] VARCHAR(20),  
        [Avg Frag %] decimal(5,2), [Row Ct] bigint, [Stats Update Dt] datetime )  


		/*** Tebela que vai receber a relação de Database do servidor ***/
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
			)
			

		/*** Declaração de variaveis ***/	
		DECLARE @DatabaseName sysname
		SET   @DatabaseName = ''

/******* Alimenta a tabela temporaria com as Database do servidor *********/

		INSERT INTO #TempDatabasesTable ([DatabaseName]) 
			SELECT name
			FROM master..sysdatabases 
			WHERE dbid > 4 and version is not null and version <> 0



/*** Esta rotina de loop será responsavel por alimentar a tabela temporaria ****/
/***        Com todas as base e seus respetivos usuário com suas roles      ****/ 

WHILE @DatabaseName is not null  --- Enquanto a variavel @DatabaseName estiver com seu valor diferente de null continuar o loop
	BEGIN
		SET @DatabaseName = NULL

		SELECT TOP 1 @DatabaseName = [DatabaseName] 
			from #TempDatabasesTable 
			where Mod = 1

		IF @DatabaseName is NULL
			break
		
			declare @SqlCommand nvarchar(4000)

---------------------------------------------------------------------------------- 
-- ******VARIABLE DECLARATIONS****** 
---------------------------------------------------------------------------------- 
			set @SqlCommand = 'USE ['+ @DatabaseName  +']' 
            + ' ' +
		   'DECLARE @table_name sysname 
			DECLARE @dbid smallint --Database id for current database 
			DECLARE @objectid INT    --Object id for table being analyzed 
			DECLARE @indexid INT     --Index id for the target index for the STATS_DATE() function 

			DECLARE curTable CURSOR FOR  
				SELECT  OB.name 
				FROM SYSOBJECTS OB
				WHERE XTYPE=''U'' AND category =''0'' AND OB.name NOT LIKE ''%bkp%''
				ORDER BY OB.name
  
				OPEN curTable  
				   FETCH NEXT FROM curTable INTO @table_name  
				    
					   WHILE @@FETCH_STATUS = 0  
						   BEGIN  
							
							SELECT @dbid = DB_ID(DB_NAME())  
							SELECT @objectid = OBJECT_ID(@table_name)  


									INSERT INTO #IndexTable  
									   ( 
									   [Database], [Table], [Index Name], index_id, [object_id],  
									   [Index Type], [Alloc Unit Type], [Avg Frag %], [Row Ct] 
									   ) 
									SELECT  
									   DB_NAME() AS "Database",  
									   @table_name AS "Table",  
									   SI.NAME AS "Index Name",  
									   IPS.index_id, IPS.OBJECT_ID,      
									   IPS.index_type_desc, 
									   IPS.alloc_unit_type_desc, 
									   CAST(IPS.avg_fragmentation_in_percent AS decimal(5,2)),  
									   IPS.record_count  
									FROM sys.dm_db_index_physical_stats (@dbid, @objectid, NULL, NULL, ''sampled'') IPS  
									   LEFT JOIN sys.sysindexes SI ON IPS.OBJECT_ID = SI.id AND IPS.index_id = SI.indid  
									WHERE IPS.index_id <> 0  					
									

							   FETCH NEXT FROM curTable INTO @table_name  
						   END  
				CLOSE curTable  
				DEALLOCATE curTable 

				DECLARE curIndex_ID CURSOR FOR  
				   SELECT I.index_id  
				   FROM #IndexTable I  
				   ORDER BY I.index_id  
				    
				OPEN curIndex_ID  
				   FETCH NEXT FROM curIndex_ID INTO @indexid  
				    
				   WHILE @@FETCH_STATUS = 0  
					   BEGIN  
						   UPDATE #IndexTable  
						   SET [Stats Update Dt] = STATS_DATE(@objectid, @indexid)  
						   WHERE [object_id] = @objectid AND [index_id] = @indexid  
				            
						   FETCH NEXT FROM curIndex_ID INTO @indexid  
					   END  
				    
				CLOSE curIndex_ID  
				DEALLOCATE curIndex_ID'
    
---------------------------------------------------------------------------------- 
-- ******RETURN RESULTS****** 
---------------------------------------------------------------------------------- 
				exec sp_executesql @SqlCommand
				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName
	END

SELECT I.[Database], I.[Table], I.[Index Name], "Index Type"= 
   CASE I.[Index Type] 
       WHEN 'NONCLUSTERED INDEX' THEN 'NCLUST' 
       WHEN 'CLUSTERED INDEX' THEN 'CLUST' 
       ELSE 'HEAP' 
   END,  
   I.[Avg Frag %], 
   I.[Row Ct],  
   CONVERT(VARCHAR, I.[Stats Update Dt], 110) AS "Stats Dt"
FROM #IndexTable AS I
WHERE I.[Avg Frag %] > 30
ORDER BY I.[Database], I.[Table], I.[Index Name] 

DROP TABLE #IndexTable
DROP TABLE #TempDatabasesTable
GO


