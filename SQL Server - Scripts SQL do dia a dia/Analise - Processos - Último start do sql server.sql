--- Último start do sql server

SELECT
            SERVERPROPERTY('MachineName') AS [ServerName], 
			SERVERPROPERTY('ServerName') AS [ServerInstanceName], 
            SERVERPROPERTY('InstanceName') AS [Instance], 
            SERVERPROPERTY('Edition') AS [Edition],
            SERVERPROPERTY('ProductVersion') AS [ProductVersion], 
			Left(@@Version, Charindex('-', @@version) - 2) As VersionName

SELECT sqlserver_start_time FROM sys.dm_os_sys_info