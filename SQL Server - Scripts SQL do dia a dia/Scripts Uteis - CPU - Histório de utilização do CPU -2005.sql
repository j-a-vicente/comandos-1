WITH ScheduleMonitorResults AS
(
    SELECT 
      DATEADD(ms, 
        (select [ms_ticks]-[timestamp] from sys.dm_os_sys_info), 
        GETDATE())          AS 'EventDateTime', 
      CAST(record AS xml)   AS 'record'
    FROM sys.dm_os_ring_buffers
    WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR' 
    AND    [timestamp] > 
               (select [ms_ticks] - 60*60000  -- Last 10 minutes
                                  - 100       -- Round up 
                from sys.dm_os_sys_info)
)
SELECT 
    SysHealth.value('ProcessUtilization[1]','int') AS 'SQL Server Process CPU Utilization',
    SysHealth.value('SystemIdle[1]','int') AS 'System Idle Process',   
    (SysHealth.value('ProcessUtilization[1]','int') + (101- SysHealth.value('SystemIdle[1]','int'))) AS 'Other Process CPU Utilization',
    CONVERT (varchar, EventDateTime, 126) AS EventTime
FROM ScheduleMonitorResults CROSS APPLY 
    record.nodes('/Record/SchedulerMonitorEvent/SystemHealth') T(SysHealth)
ORDER BY EventDateTime DESC