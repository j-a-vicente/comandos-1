-- Individual File Sizes and space available for current database
SELECT name AS [File Name] , physical_name AS [Physical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB], [file_id]
FROM sys.database_files OPTION (RECOMPILE);