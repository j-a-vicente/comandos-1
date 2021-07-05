SELECT M1.object_name 
     , M1.cntr_value AS 'Total de Mémoria em uso pelo SQL'
     , M2.cntr_value AS 'Total de Mémoria Disponivel para SQL'
     , M3.cntr_value AS 'User Connections'
     , M4.cntr_value AS 'Connection Memory (KB)'
     
FROM sys.dm_os_performance_counters as M1,
     sys.dm_os_performance_counters as M2,
     sys.dm_os_performance_counters as M3,
     sys.dm_os_performance_counters as M4
     
WHERE M1.counter_name = 'Total Server Memory (KB)'
AND   M2.counter_name = 'Target Server Memory (KB)'
AND   M3.[counter_name] = 'User Connections'
AND   M4.[counter_name] = 'Connection Memory (KB)'