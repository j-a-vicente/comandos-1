/*
Para execução do script é preciso se conectar no SQL Server via DAC (Dedicated Administrator Connection).




*/
USE master
GO
CREATE PROC dbo.SP_Descriptografa_Objeto
 
/*******************************************************************************************************
 Nome: dbo.SP_Descriptografa_Objeto
 Adaptações: Patrocinio Maia
 Link Referência: http://jongurgul.com/blog/sql-object-decryption/
 DESCRIÇÃO: Faz a Descriptografia de qualquer objeto no Banco de Dados. Para rodá-la é necessário estar conectado via DAC (Dedicated Administrator Connection) "admin:NomeServer".
 Basicamente esta procedure faz um SELECT na "sys.sysobjvalues", coluna imageval do banco e objeto especificado.
 MODO DE USO: EXEC master.dbo.SP_Descriptografa_Objeto 'NomeBanco', 'NomeObjeto'
 Compilação...: SQL SERVER 2008 R2
 ******************************************************************************************************/ 
 
@NomeBanco varchar(300),@NomeObjeto varchar(300)
 
WITH ENCRYPTION
 
AS
BEGIN 
DECLARE @ImprimeCodigoEncriptado NVARCHAR(MAX) =
 
N'
DECLARE @EncObj VARBINARY(MAX)
 ,@DummyEncObj VARBINARY(MAX)
 ,@ObjectNameStmTemplate NVARCHAR(MAX)
 
SET NOCOUNT ON
 
 USE '+@NomeBanco+'
 
DECLARE @object_id INT
 ,@name SYSNAME
 
SELECT @object_id = [object_id]
 ,@name = [name]
FROM sys.all_objects
WHERE NAME = N'''+@NomeObjeto+'''
 
SELECT TOP 1 @ObjectNameStmTemplate = [ObjectStmTemplate]
 ,@EncObj = [imageval]
FROM (
 SELECT SPACE(1) + (
 CASE
 WHEN [type] = ''P''
 THEN N''PROCEDURE''
 WHEN [type] = ''V''
 THEN ''VIEW''
 WHEN [type] IN (
 ''FN''
 ,''TF''
 ,''IF''
 )
 THEN N''FUNCTION''
 WHEN [type] IN (''TR'')
 THEN N''TRIGGER''
 ELSE [type]
 END
 ) + SPACE(1) + QUOTENAME(SCHEMA_NAME([schema_id])) + ''.'' + QUOTENAME(ao.[name]) + SPACE(1) + (
 CASE
 WHEN [type] = ''P''
 THEN N''WITH ENCRYPTION AS''
 WHEN [type] = ''V''
 THEN N''WITH ENCRYPTION AS SELECT 123 ABC''
 WHEN [type] IN (''FN'')
 THEN N''() RETURNS INT WITH ENCRYPTION AS BEGIN RETURN 1 END''
 WHEN [type] IN (''TF'')
 THEN N''() RETURNS @t TABLE(i INT) WITH ENCRYPTION AS BEGIN RETURN END''
 WHEN [type] IN (''IF'')
 THEN N''() RETURNS TABLE WITH ENCRYPTION AS RETURN SELECT 1 N''
 WHEN [type] IN (''TR'')
 THEN N'' ON '' + OBJECT_NAME(ao.[parent_object_id]) + '' WITH ENCRYPTION FOR DELETE AS SELECT 1 N''
 ELSE [type]
 END
 ) + REPLICATE(CAST(N''-'' AS NVARCHAR(MAX)), DATALENGTH(sov.[imageval])) COLLATE DATABASE_DEFAULT
 ,sov.[imageval]
 FROM sys.all_objects ao
 INNER JOIN sys.sysobjvalues sov ON sov.[valclass] = 1
 AND ao.[Object_id] = sov.[objid]
 WHERE [type] NOT IN (
 ''S''
 ,''U''
 ,''PK''
 ,''F''
 ,''D''
 ,''SQ''
 ,''IT''
 ,''X''
 ,''PC''
 ,''FS''
 ,''AF''
 ,''TR''
 )
 AND ao.[object_id] = @object_id
 
 UNION ALL
 
 --Server Triggers
 
 SELECT SPACE(1) + ''TRIGGER'' + SPACE(1) + QUOTENAME(st.[name]) + SPACE(1) + N''ON ALL SERVER WITH ENCRYPTION FOR DDL_LOGIN_EVENTS AS SELECT 1'' + REPLICATE(CAST(N''-'' AS NVARCHAR(MAX)), DATALENGTH(sov.[imageval])) COLLATE DATABASE_DEFAULT
 ,sov.[imageval]
 FROM sys.server_triggers st
 INNER JOIN sys.sysobjvalues sov ON sov.[valclass] = 1
 AND st.[object_id] = sov.[objid]
 WHERE st.[object_id] = @object_id
 --Database Triggers
 
 UNION ALL
 
 SELECT SPACE(1) + ''TRIGGER'' + SPACE(1) + QUOTENAME(dt.[name]) + SPACE(1) + N''ON DATABASE WITH ENCRYPTION FOR CREATE_TABLE AS SELECT 1'' + REPLICATE(CAST(N''-'' AS NVARCHAR(MAX)), DATALENGTH(sov.[imageval])) COLLATE DATABASE_DEFAULT
 ,sov.[imageval]
 FROM sys.triggers dt
 INNER JOIN sys.sysobjvalues sov ON sov.[valclass] = 1
 AND dt.[object_id] = sov.[objid]
 AND dt.[parent_class_desc] = ''DATABASE''
 WHERE dt.[object_id] = @object_id
 ) x([ObjectStmTemplate], [imageval])
 
--Altera o objeto existente, em seguida, reverte para que possamos ter o valor do objeto criptografado dummy
BEGIN TRANSACTION
 
DECLARE @sql NVARCHAR(MAX)
 
SET @sql = N''ALTER'' + @ObjectNameStmTemplate
 
EXEC sp_executesql @sql
 
SELECT @DummyEncObj = sov.[imageval]
FROM sys.all_objects ao
INNER JOIN sys.sysobjvalues sov ON sov.[valclass] = 1
 AND ao.[Object_id] = sov.[objid]
WHERE ao.[object_id] = @object_id
 
ROLLBACK TRANSACTION
 
DECLARE @Final NVARCHAR(MAX)
 
SET @Final = N''''
 
DECLARE @Pos INT
 
SET @Pos = 1
 
WHILE @Pos <= DATALENGTH(@EncObj) / 2
BEGIN
 SET @Final = @Final + NCHAR(UNICODE(SUBSTRING(CAST(@EncObj AS NVARCHAR(MAX)), @Pos, 1)) ^ (UNICODE(SUBSTRING(N''CREATE'' + @ObjectNameStmTemplate, @Pos, 1)) ^ UNICODE(SUBSTRING(CAST(@DummyEncObj AS NVARCHAR(MAX)), @Pos, 1))))
 SET @Pos = @Pos + 1
END
 
IF DATALENGTH(@Final) <= 8000
BEGIN
 PRINT @Final
END
ELSE
BEGIN
 DECLARE @c INT
 
 SET @c = 0
 
 WHILE @c <= (DATALENGTH(@Final) / 8000)
 BEGIN
 PRINT SUBSTRING(@Final, 1 + (@c * 4000), 4000)
 
 SET @c = @c + 1
 END
END'
 
--Faz a mágica
EXEC(@ImprimeCodigoEncriptado)
END


/*
 Para descriptografar todas as SP e FC utlizar o script abaixo.
*/
USE KIT20_CPE2020
GO

DECLARE @SPECIFIC_SCHEMA NVARCHAR(255), @ROUTINE_NAME NVARCHAR(255), @export NVARCHAR(MAX) = ''
DECLARE @RC NVARCHAR(MAX) 
DECLARE @NomeBanco varchar(300)  = 'KIT20_CPE2020'
DECLARE @NomeObjeto varchar(300)

DECLARE @fc TABLE
	(script nvarchar(max)
)


DECLARE fc_sp CURSOR FOR 
  
	SELECT
		SPECIFIC_SCHEMA,
		ROUTINE_NAME
	FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINE_DEFINITION IS NULL
	  AND ROUTINE_NAME <> 'SP_Descriptografa_Objeto'
	ORDER BY SPECIFIC_SCHEMA,ROUTINE_NAME

OPEN fc_sp  
  
FETCH NEXT FROM fc_sp  INTO @SPECIFIC_SCHEMA, @ROUTINE_NAME  
  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

		SET @NomeObjeto =  @ROUTINE_NAME

		   EXEC [dbo].[SP_Descriptografa_Objeto] @NomeBanco  ,@NomeObjeto

			FETCH NEXT FROM fc_sp  INTO @SPECIFIC_SCHEMA, @ROUTINE_NAME  
		END   
CLOSE fc_sp;  
DEALLOCATE fc_sp;  








/*
Referência
https://patrociniomaia.wordpress.com/2014/12/12/descriptografando-procedures-e-funtions-with-encryption/
*/