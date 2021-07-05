select @@servername as 'servidor'
     , db.name as 'NameDatabese'
     , mf.name as 'NameFiles'
     , round((mf.size * 8) / 1024 ,2) as 'dbsize'
	 , CASE 
		 WHEN mf.max_size = -1 THEN 0
		 WHEN mf.max_size = 268435456 THEN 0
		 ELSE round((mf.max_size * 8) / 1024 ,2)
	   END AS 'max_size'
     , CASE
	     WHEN mf.growth = 0 THEN 'Arquivo com tamanho fixo'     
		 WHEN mf.growth > 0 THEN 'Arquivo com tamanho automático'
	   END AS 'growth'
     , CASE 
		WHEN mf.is_percent_growth = '0' THEN RTRIM(CAST(round((mf.growth * 8) / 1024 ,2) as VarChar(10)))
		WHEN mf.is_percent_growth = '1' THEN RTRIM(CAST(mf.growth as VarChar(10))) + '%'
		END AS 'txc' 
	 , GETDATE()	 
from sys.master_files as mf
inner join sysdatabases as db on db.dbid = mf.database_id