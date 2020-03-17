select DB_NAME(dbid)'database',
       loginame,
       cpu,
       hostname,
       program_name,
       status,
       blocked,
       spid ,
       login_time,
       GETDATE()as 'horas Atual',
       DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) as tempo
from sysprocesses
where  
	  DB_NAME(dbid) = 'mcscv' 
	  /*or DB_NAME(dbid) = 'SISTAPOIOPORTAL' 
	  or DB_NAME(dbid) = 'PRD_OT_WEMAUDIT_DB'
	  or DB_NAME(dbid) = 'PRD_OT_WEMMGMT_DB' 
	  or DB_NAME(dbid) = 'PRD_OT_WEMSYS_DB' 	  
	  or DB_NAME(dbid) = 'PRD_OT_WEMLIVE_DB' 
	  or DB_NAME(dbid) = 'PRD_OT_PORTALLIVE_DB'
	  or DB_NAME(dbid) = 'PRD_OT_WEMLIVE_DB'
	  AND*/
	 --  program_name LIKE '%Management%'
	 -- AND
      --loginame like '%suporte%'  --Buscar por login
	  --AND
	  --hostname = '%NASRVCORTEX02%' --Buscar por Hostname
	  --AND	  
      --blocked <> 0  --Busca o processo que estão com bloqueio
	  --AND	        
	  --DB_NAME(dbid) = 'SIACNet' --Buscar por Database
	  --AND	  	  
	  --DATEDIFF(MI, login_time ,CONVERT(datetime, GETDATE(),121) ) >= 15 AND (not DB_NAME(dbid) = 'master' AND not DB_NAME(dbid) = 'model' AND not DB_NAME(dbid) = 'msdb' AND not DB_NAME(dbid) = 'temp') --Buscar por processo com mais de 15 min. de execução
	  --AND	  
      --status = 'runnable'
order by  login_time, spid --Ordem a qual será visualizado