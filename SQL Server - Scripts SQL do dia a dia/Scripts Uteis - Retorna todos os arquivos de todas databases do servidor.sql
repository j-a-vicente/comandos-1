
select @@servername
     , d.name as NameDatabese
     , f.name as NameFiles
     , f.filename 
     , f.size
from sysaltfiles f 
inner join sysdatabases d
 on (f.dbid = d.dbid)
 order by 1,2