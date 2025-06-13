SELECT
    request_id,
    status,
    total_elapsed_time,
    command,
    submit_time,
    end_time,
    resource_class
FROM sys.dm_pdw_exec_requests
WHERE submit_time >= DATEADD(day, -1, GETDATE())
  AND session_id <> SESSION_ID()
  AND status = 'Running'
ORDER BY total_elapsed_time DESC;
