USE [master]
GO

/******* Criação das trabelas temporarias *********/

		/*** Tebela que vai receber a relação de Database do servidor ***/
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
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
						'INSERT INTO [NASVCSRVSQL01_DBDOC].[MonitoramentoDBA].[dbo].[MonitoramentoIndexNUtilizado]
								   ([idServidor]
								   ,[DatabaseName]
								   ,[Tabela]
								   ,[Index]
								   ,[Pesquisa]
								   ,[Varreduras]
								   ,[LookUps]
								   ,[UltimaPesquisa]
								   ,[UltimaVarreduras]
								   ,[UltimaLookUps])
						SELECT s.idserver as servidor,
							Banco, Tabela, Indice, Pesquisas, Varreduras, LookUps,
							UltimaPesquisa, UltimaVarredura, UltimoLookUp
						FROM (SELECT
								DB_NAME(database_id) As Banco, OBJECT_NAME(Ia.object_id) As Tabela, Ia.Name As Indice,
								U.User_Seeks As Pesquisas, U.User_Scans As Varreduras, U.User_Lookups As LookUps,
								U.Last_User_Seek As UltimaPesquisa, U.Last_User_Scan As UltimaVarredura,
								U.Last_User_LookUp As UltimoLookUp, U.Last_User_Update As UltimaAtualizacao
							  FROM sys.indexes As Ia
							  LEFT OUTER JOIN sys.dm_db_index_usage_stats As U ON Ia.object_id = U.object_id AND Ia.index_id = U.index_id
							  WHERE database_id = DB_ID() ) AS IndicesNaoUtilizados
						INNER JOIN [NASVCSRVSQL01_DBDOC].[MonitoramentoDBA].[dbo].[Servidores] AS S ON S.Servidor = @@SERVERNAME	  
						WHERE (Pesquisas + Varreduras + LookUps) = 0 '
			
			
				exec sp_executesql @SqlCommand				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName		

	end



	
DROP TABLE #TempDatabasesTable



GO


