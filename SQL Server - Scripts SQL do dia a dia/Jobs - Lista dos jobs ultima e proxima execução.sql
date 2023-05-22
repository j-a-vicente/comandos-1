SELECT j.[name],
MAX(CAST(
STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' +
STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime)) AS [LastRun],
MAX(CAST(
STUFF(STUFF(CAST(sjs.next_run_date as varchar),7,0,'-'),5,0,'-') + ' ' +
STUFF(STUFF(REPLACE(STR(sjs.next_run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime)) AS [NextRun],
CASE jh.run_status WHEN 0 THEN 'Failed'
WHEN 1 THEN 'Success'
WHEN 2 THEN 'Retry'
WHEN 3 THEN 'Canceled'
WHEN 4 THEN 'In progress'
END AS Status
,'Last Run Message' = LASTRUN.message
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory jh ON jh.job_id = j.job_id AND jh.step_id = 0
INNER JOIN msdb.dbo.syscategories sc on j.category_id = sc.category_id
INNER JOIN MSDB.dbo.sysjobschedules sjs on j.job_id = sjs.Job_id
LEFT OUTER JOIN (SELECT J1.job_id,J1.RUN_DURATION,J1.run_date,J1.run_time,J1.message,J1.run_status
				  FROM msdb.dbo.sysjobhistory J1
				  WHERE J1.instance_id = (SELECT MAX(instance_id)
										FROM msdb.dbo.sysjobhistory J2
										 WHERE J2.job_id = J1.job_id)) LASTRUN ON J.job_id = LASTRUN.job_id
GROUP BY j.[name], jh.run_status,LASTRUN.message