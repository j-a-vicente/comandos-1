SELECT --TOP 1
       s.database_name,
       m.physical_device_name,
       CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
       CAST(DATEDIFF(second, s.backup_start_date,
       s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken,
       s.backup_start_date,
       backup_finish_date,
       CASE s.[type]
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
       END AS BackupType,
       s.server_name,
       s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
INNER JOIN (SELECT database_name, MAX(backup_start_date) [backup_start_date]
             FROM msdb.dbo.backupset
			 GROUP BY database_name) b ON b.database_name = s.database_name and b.[backup_start_date] = s.backup_start_date
ORDER BY s.database_name 
GO