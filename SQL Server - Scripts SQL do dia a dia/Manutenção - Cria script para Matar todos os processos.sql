select 'kill ' + CONVERT(varchar, spid) 
from sysprocesses
--where  	 
    /*DB_NAME(dbid) = 'PRD_OT_WEMSYS_DB' 
	  or DB_NAME(dbid) = 'SISTAPOIOPORTAL' 
	  or DB_NAME(dbid) = 'PRD_OT_WEMAUDIT_DB' 	  */
	  --AND	  	  
	  --DATEDIFF(MI, login_time ,CONVERT(datetime, GETDATE(),121) ) >= 15 AND (not DB_NAME(dbid) = 'master' AND not DB_NAME(dbid) = 'model' AND not DB_NAME(dbid) = 'msdb' AND not DB_NAME(dbid) = 'temp') --Buscar por processo com mais de 15 min. de execução
	  --AND	
      --DB_NAME(dbid) = 'RodadadeNegocios'
      --AND
      --spid >= 50    and not DB_NAME(dbid) = 'master' 		and DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) >= 15
