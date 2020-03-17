select blocking.blocking_session_id
from sys.dm_os_waiting_tasks blocking inner join sys.dm_os_waiting_tasks blocked
on blocking.session_id = blocked.blocking_session_id