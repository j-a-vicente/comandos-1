
select a.name 
     , b.db_size
     , a.crdate
     , a.dbid
from sysdatabases a
inner join (select d.name , ((sum(f.size)*8)/1024) as 'db_size'
			from sysaltfiles f 
			inner join sysdatabases d on (f.dbid = d.dbid)
			group by d.name) as b on b.name = a.name