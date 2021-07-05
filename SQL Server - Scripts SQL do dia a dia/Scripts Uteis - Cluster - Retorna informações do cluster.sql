/* Informáções do servidor que está em cluster  */

SELECT * FROM sys.dm_os_cluster_nodes
SELECT * FROM sys.dm_os_nodes
SELECT * FROM fn_virtualservernodes() 
SELECT * FROM fn_servershareddrives()
SELECT * FROM sys.dm_io_cluster_shared_drives

EXEC XP_FIXEDDRIVES

SELECT * FROM fn_servershareddrives() 

SELECT * FROM sys.dm_io_cluster_shared_drives 
