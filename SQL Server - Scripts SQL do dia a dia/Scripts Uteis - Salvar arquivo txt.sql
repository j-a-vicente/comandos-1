declare @servidor varchar(50)
      , @usuario varchar(20)
      , @senha varchar(20)
      , @banco varchar(30)
      , @procedure varchar(80)
      , @arquivoFisico varchar(50)
      , @comando varchar(250)

set @servidor = '10.1.140.67\TESTE,1434'
set @usuario = 'consultasebrae'
set @senha = 'sebrae=consulta'
set @banco = 'master'
set @procedure = 'EXECUTE [master].[dbo].[SP_Monitor_TopQueryMaisUsadas] ' --poderia ser uma stored Procedure também
set @arquivoFisico = '\\10.1.141.221\BackupsDC\67Teste.xml'
set @comando = 'sqlcmd -S '+@servidor+' -U '+@usuario+' -P '+@senha+' -d '+@banco+' -q "'+@Procedure+'" -s ";" -o '+@arquivoFisico
--print(@comando)

exec master.dbo.xp_cmdshell @comando