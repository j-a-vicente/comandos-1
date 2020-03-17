USE [master]
GO

/* *************************************************************************************************/
/*                     Estes script tem a finalidade de monitora todas as bases                    */
/*                            e seus resulados seram utilizados                                    */
/*                                para cria��o de  relatorios								       */
/***************************************************************************************************/

 ----------------------------------------------------------------------------------------------------
 ---- Descri��o do Script 
 ---- Este script lista todas os usu�rios com acesso direto ao Database e suas permiss�es.
 ----		1� Listas os usu�rios das Databases
 ----		2� Listas o nivel de acesso de cada usu�rio
 ----		3� Verifica se o usu�rio existe no servidor se n�o adiciona
 ----		4� Verifica se o usu�rio que esta no servidor foi retirado da Database, se sim ele e desativado
 ----		5� Verifica se o usu�rio que foi desativa voltou a ser ativo e atualzia o mesmo. 
 ----------------------------------------------------------------------------------------------------


/******* Cria��o das trabelas temporarias *********/

		/*** Tebela que vai receber a rela��o de Database do servidor ***/
		CREATE TABLE #TempDatabasesTable
			(
				[DatabaseName] sysname not null primary key,
				Mod tinyint not null default 1
			)
			
		/*** Tebela que vai receber as contas com acesso a base de dados ***/
		CREATE TABLE #PermissionsDB(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[DbRole] [varchar](100) NULL,
			[MemberName] [nvarchar](100) NULL
			)



/******* Alimenta a tabela temporaria com as Database do servidor *********/

		INSERT INTO #TempDatabasesTable ([DatabaseName]) 
			SELECT name--,dbid
			FROM master..sysdatabases 
			WHERE dbid > 4 and version is not null and version <> 0
	

/*** Declara��o de variaveis ***/	
		DECLARE @DatabaseName sysname
		SET   @DatabaseName = ''


/*** Esta rotina de loop ser� responsavel por alimentar a tabela temporaria ****/
/***        Com todas as base e seus respetivos usu�rio com suas roles      ****/ 

WHILE @DatabaseName is not null  --- Enquanto a variavel @DatabaseName estiver com seu valor diferente de null continuar o loop
	BEGIN
		SET @DatabaseName = NULL

		SELECT TOP 1 @DatabaseName = [DatabaseName] 
			from #TempDatabasesTable 
			where Mod = 1

		IF @DatabaseName is NULL
			break
		
			declare @SqlCommand nvarchar(4000)

	        -- Se o servidor de sql for da vers�o 2008 executa este script.
			IF EXISTS(select @@version where @@version like '%Microsoft SQL Server 2008%' or @@VERSION LIKE 'Microsoft SQL Server 2012%')
			Begin

				set @SqlCommand = 'USE ['+ @DatabaseName  +']' 
									+'  '+
								   'insert into #PermissionsDB
								   ([Servidor],
									[base],
									[DbRole],
									[MemberName])
								   (select @@SERVERNAME as  [Servidor]
										 ,''' + @DatabaseName + ''' as base
										 , g.name as  [DbRole]
										 , u.name as [MemberName]
									from sys.database_principals u
									, sys.database_principals g
									, sys.database_role_members m 
									where g.principal_id = m.role_principal_id and u.principal_id = m.member_principal_id)'				
				exec sp_executesql @SqlCommand
				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName

			End
			Else -- Se n�o for 2008, verifica se e da vers�o 2000
			IF EXISTS(select @@version where @@version like '%Microsoft SQL Server  2000%' or @@version like '%Microsoft SQL Server 2005%')
			Begin
				
				set @SqlCommand = 'USE ['+ @DatabaseName  +']' 
									+'  '+
								   'insert into #PermissionsDB
								   ([Servidor],
									[base],
									[DbRole],
									[MemberName])
								   (select  @@SERVERNAME as  [Servidor]
										  , ''' + @DatabaseName + ''' as base
										  , USER_NAME(groupuid) AS [Role]
										  , USER_NAME(memberuid) AS [User]
									FROM  sysmembers)'				
				exec sp_executesql @SqlCommand				
				update #TempDatabasesTable set Mod = 0 where [DatabaseName] = @DatabaseName
					
			End	

	end

--SELECT * FROM #PermissionsDB pdb
				   
/**** Role e user n�o existe no servidor ****/ 

SELECT * 
FROM #PermissionsDB pdb
		
                        
DROP TABLE #TempDatabasesTable

DROP TABLE #PermissionsDB 





GO


