	
	   /* Tabela temporaria com as Database do servidor */		
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
			)
			

		/* Alimenta a tabela temporaria com as Database do servidor */
		INSERT INTO #TempDatabasesTable ([DatabaseName]) 
			SELECT [name]
			FROM master..sysdatabases 
			WHERE dbid > 4 and version is not null and version <> 0 and status <> '48'
	

		/* Declaração de variaveis */	
		DECLARE @DatabaseName VARCHAR(1000)
		SET   @DatabaseName = ''


/*** Esta rotina de loop será responsavel por alimentar a tabela temporaria ****/
/***        Com todas as base e seus respetivos arquivos      ****/ 

WHILE @DatabaseName is not null  --- Enquanto a variavel @DatabaseName estiver com seu valor diferente de null continuar o loop
	BEGIN
		SET @DatabaseName = NULL

		SELECT TOP 1 @DatabaseName = [DatabaseName] 
			from #TempDatabasesTable 
			where Mod = 1

		IF @DatabaseName is NULL
			break
		
			declare @SqlCommand nvarchar(4000)

				set @SqlCommand =  ' ALTER DATABASE ['+ @DatabaseName +'] SET RECOVERY SIMPLE WITH NO_WAIT '
				
				exec sp_executesql @SqlCommand
				
				set @SqlCommand =  ' USE [' + @DatabaseName +']'
								  +' '
								  +' DBCC SHRINKDATABASE(N''' + @DatabaseName +''' )'				
				PRINT @SqlCommand
				exec sp_executesql @SqlCommand				
			
				--Para voltar as tabases para RECOVERY FULL descomente as duas próximas linhas
				--set @SqlCommand =  ' ALTER DATABASE ['+ @DatabaseName +'] SET RECOVERY FULL WITH NO_WAIT '
				--exec sp_executesql @SqlCommand
				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName
	END
	
DROP TABLE #TempDatabasesTable

	