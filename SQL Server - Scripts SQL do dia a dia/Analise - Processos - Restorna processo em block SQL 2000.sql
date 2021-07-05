select blocking.spid
from master.dbo.sysprocesses blocking inner join master.dbo.sysprocesses blocked 
on blocking.spid = blocked.blocked
where blocking.blocked = 0