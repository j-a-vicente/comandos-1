USE master
 
SELECT TOP 10 st.text [TSQL], DB_NAME(st.dbid) [DB], cp.usecounts [ExecutionCount],
 qs.total_elapsed_time/cp.usecounts/1000000.0 [AvgElapsedTime(sec)], 
 qs.last_elapsed_time/1000000.0 [LastElapsedTime(sec)], qs.max_elapsed_time/1000000.0 [MaxElapsedTime(sec)], 
 qs.min_elapsed_time/1000000.0 [MinElapsedTime(sec)], qs.total_elapsed_time/1000000.0 [TotalElapsedTime(sec)],
 qs.total_worker_time/cp.usecounts/1000000.0 [AvgCPUTime(sec)], 
 qs.last_worker_time/1000000.0 [LastCPUTime(sec)], qs.max_worker_time/1000000.0 [MaxCPUTime(sec)], 
 qs.min_worker_time/1000000.0 [MinCPUTime(sec)], qs.total_worker_time/1000000.0 [TotalCPUTime(sec)], 
 qs.total_logical_reads/cp.usecounts [AvgLogicalRead], 
 qs.last_logical_reads, qs.max_logical_reads, qs.min_logical_reads, qs.total_logical_reads, 
 qs.last_physical_reads [LastPhysicalRead], qs.max_physical_reads, qs.min_physical_reads, qs.total_physical_reads,  
 qs.total_logical_writes/cp.usecounts [AvgLogicalWrite], qs.last_logical_writes,
 qs.max_logical_writes, qs.min_logical_writes, qs.total_logical_writes,
 qs.last_rows [LastRows], qs.max_rows, qs.min_rows, qs.total_rows, 
 qp.query_plan [QueryPlan], cp.plan_handle, cp.size_in_bytes/1024.0 [PlanSize(KB)],
 cp.cacheobjtype [CacheObject], cp.objtype [ObjType], qs.plan_generation_num [PlanRecompile],
 st.objectid, qs.last_execution_time, qs.creation_time --qs.*
FROM sys.dm_exec_cached_plans cp INNER JOIN sys.dm_exec_query_stats qs
         ON cp.plan_handle = qs.plan_handle
 CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
 CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.dbid = DB_ID('AdventureWorks2014')
-- CHARINDEX ('Products', st.text) >0
-- st.text LIKE '%xxx%'
ORDER BY [ExecutionCount] DESC;


SELECT TOP 25
    execution_count, plan_generation_num, last_execution_time,
    total_worker_time, last_worker_time, min_worker_time, max_worker_time,
    total_logical_reads, last_logical_reads, min_logical_reads,  max_logical_reads,
    total_physical_reads, last_physical_reads, min_physical_reads,  max_physical_reads,
    total_logical_writes, last_logical_writes, min_logical_writes, max_logical_writes,
     total_elapsed_time, last_elapsed_time, min_elapsed_time, max_elapsed_time,
    (SUBSTRING(s2.text,  statement_start_offset / 2, ( (CASE WHEN statement_end_offset = -1 THEN
    (LEN(CONVERT(nvarchar(max),s2.text)) * 2) ELSE statement_end_offset END)  - statement_start_offset) / 2)  )  AS sql_statement,
        text, p.query_plan
 
FROM sys.dm_exec_query_stats qs
     CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) s2
     CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) P
ORDER BY total_physical_reads DESC