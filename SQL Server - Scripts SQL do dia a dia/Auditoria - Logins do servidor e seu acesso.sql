SELECT 
	    L.name      AS 'Nome'
	   ,L.loginname AS 'Login'
	   ,L.dbname    AS 'DefaultDatabase'
	   ,L.isntname  AS 'LoginTipoSqlWnt'
	   ,L.sysadmin
	   ,L.securityadmin
	   ,L.serveradmin
	   ,L.setupadmin
	   ,L.processadmin
	   ,L.diskadmin
	   ,L.dbcreator
	   ,L.bulkadmin
from syslogins as L