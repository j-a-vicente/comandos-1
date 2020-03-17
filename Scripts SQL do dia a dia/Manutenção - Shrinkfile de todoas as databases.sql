	
	   /* Tabela temporaria com as Database do servidor */		
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
			)
			
		/* Tebela que vai receber os nomes dos arquivos das base de dados */
		CREATE TABLE #TempDatabaseFile(
			[FileName] [varchar](500) NULL,
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
		DECLARE @FileName VARCHAR(500)
		SET @FileName = ''


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
								  +' insert into #TempDatabaseFile ([FileName]) '
								  +' select name from sysfiles '
				
				
				exec sp_executesql @SqlCommand
				SET @FileName = ''
				
					WHILE @FileName is not null
						BEGIN
							SET @FileName = NULL
							
							SELECT TOP 1 @FileName = [FileName] 
							FROM #TempDatabaseFile
							WHERE Mod = 1
							
							IF @FileName IS NULL
								break
								
								DECLARE @Shrinkfile nvarchar(4000)
								
								SET @Shrinkfile = ' USE [' + @DatabaseName + ']'
												 +' '
												 +' DBCC SHRINKFILE (N''' + @FileName + ''' , 0, TRUNCATEONLY)'
								PRINT @Shrinkfile
								exec sp_executesql @Shrinkfile			 						
								
								update #TempDatabaseFile set Mod = 0 where [FileName] = @FileName
						END
				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName
				
				DELETE FROM #TempDatabaseFile
				
				--Para voltar as tabases para RECOVERY FULL descomente as duas próximas linhas
				--set @SqlCommand =  ' ALTER DATABASE ['+ @DatabaseName +'] SET RECOVERY FULL WITH NO_WAIT '
				--exec sp_executesql @SqlCommand
	end
	
DROP TABLE #TempDatabasesTable

DROP TABLE #TempDatabaseFile
	