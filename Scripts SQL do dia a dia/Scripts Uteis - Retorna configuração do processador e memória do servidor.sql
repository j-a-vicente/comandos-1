SELECT cpu_count AS 'TotalCPULogicos', 
       hyperthread_ratio AS 'CPULogicosPPCU',
       cpu_count/hyperthread_ratio AS 'CPUFisicos', 
	   physical_memory_in_bytes/1048576 AS 'TotalMemoria(MB)', 
       sqlserver_start_time 
FROM sys.dm_os_sys_info OPTION (RECOMPILE);