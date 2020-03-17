select j.name,s.* 
from msdb.dbo.sysjobs j
join msdb.dbo.sysjobschedules s on s.job_id = j.job_id
order by j.name