SELECT hyperthread_ratio                                 'Processador fisico'
     , cpu_count                                         'Nucleos'
	 ,(SELECT cast(value as int) FROM sys.configurations
		WHERE name = 'cost threshold for parallelism')   'Limite de custo para paralelismo'
	 ,(SELECT cast(value as int) FROM sys.configurations
		WHERE name = 'max degree of parallelism')        'grau máximo de paralelismo'
	 ,(SELECT cast(value as int) FROM sys.configurations
		WHERE name = 'query wait (s)')                   'Tempo máximo de espera pela(s) memória(s) de consulta'
	 ,(SELECT cast(value as int) FROM sys.configurations
		WHERE name = 'query governor cost limit')        'Custo estimado máximo permitido pelo governador de consulta'
	 , physical_memory_kb /1024 / 1024                   'Memória fisica GB'
	 , committed_target_kb /1024 /1024                   'Memória disponivel para SQL Server GB'
	 , sqlserver_start_time                              'Data Hora da inicialização do SQL Server' 
	 , SERVERPROPERTY('Edition')                         'SQL Edition'
     , SERVERPROPERTY('ProductVersion')                  'SQL Versão' 
	 , LEFT(REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''),(CHARINDEX('Build',REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''))-2)) AS 'Sistema Operaciona'
     , LEFT(REPLACE(REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''),LEFT(REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''),(CHARINDEX('Build',REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''))-1)),''),CHARINDEX(')',REPLACE(REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''),LEFT(REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''),(CHARINDEX('Build',REPLACE(@@VERSION,LEFT(@@VERSION,(CHARINDEX('Windows',@@VERSION)-1)),''))-1)),''))-3) AS 'S.O. Versao'  
FROM sys.dm_os_sys_info OPTION (RECOMPILE);


/*
sql server automatically set processor affinity mask 
SELECT *
		FROM sys.configurations
WHERE name like '%affinity%'
  AND name like '%mask%'

affinity I/O mask  
affinity mask
affinity64 I/O mask
affinity64 mask

CPU 00 - 001
CPU 01 - 002
CPU 02 - 004
CPU 03 - 008
CPU 04 - 016
CPU 05 - 032
CPU 06 - 064
CPU 07 - 128

*/