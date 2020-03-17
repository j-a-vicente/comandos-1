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
			FROM master..sysdatabases a 
			WHERE dbid >4 and version is not null and version <> 0
			and a.[name] like 'Chronus%'
			



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
            + 'Backup database ['+ @DatabaseName  +'] to disk =N''\\10.1.141.221\Backupsdc\'+ @DatabaseName+'20150527.bak '' with compression'
   
---------------------------------------------------------------------------------- 
-- ******RETURN RESULTS****** 
---------------------------------------------------------------------------------- 
				exec sp_executesql @SqlCommand
				--print @SqlCommand
				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName
	END


DROP TABLE #IndexTable
DROP TABLE #TempDatabasesTable

GO