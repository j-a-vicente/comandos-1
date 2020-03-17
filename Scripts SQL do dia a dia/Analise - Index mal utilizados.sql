USE [master]
GO

/******* Criação das trabelas temporarias *********/

		/*** Tebela que vai receber a relação de Database do servidor ***/
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
			)
			
		CREATE TABLE #TempDataIndex
			(
				[DatabaseName] Varchar(255) NULL,
				[TableName] Varchar(255) NULL,
				[IndexName] Varchar(255) NULL,
				[IndexID] INT NULL,
				[TotalWrites] INT NULL,
				[TotalReads] INT NULL,
				[Difference] INT NULL			
			)


/******* Alimenta a tabela temporaria com as Database do servidor *********/

		INSERT INTO #TempDatabasesTable ([DatabaseName]) 
			SELECT name
			FROM master..sysdatabases 
			WHERE dbid > 4 and version is not null and version <> 0
	

/*** Declaração de variaveis ***/	
		DECLARE @DatabaseName sysname
		SET   @DatabaseName = ''


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
			
			set @SqlCommand = 'USE ['+ @DatabaseName  +']' 
						+' '+
						'INSERT INTO #TempDataIndex
							SELECT DB_NAME(database_id) as [DatabaseName] ,OBJECT_NAME(s.[object_id]) AS [TableName], i.name AS [Index Name], i.index_id,
							user_updates AS [Total Writes], user_seeks + user_scans + user_lookups AS [Total Reads],
							user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
							FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
							INNER JOIN sys.indexes AS i WITH (NOLOCK)
							ON s.[object_id] = i.[object_id]
							AND i.index_id = s.index_id							
							WHERE OBJECTPROPERTY(s.[object_id],''IsUserTable'') = 1
							AND s.database_id = DB_ID()
							AND user_updates > (user_seeks + user_scans + user_lookups)
							AND i.index_id > 1
							ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE)'
			
			
				exec sp_executesql @SqlCommand				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName		

	end

	SELECT @@SERVERNAME
	       ,[DatabaseName]
           ,[TableName]
           ,[IndexName]
           ,[IndexID]
           ,[TotalWrites]
           ,[TotalReads]
           ,[Difference]
	FROM #TempDataIndex			
	
DROP TABLE #TempDataIndex	

DROP TABLE #TempDatabasesTable


GO


