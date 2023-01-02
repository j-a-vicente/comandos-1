
WITH cte_sessoes (
	database_id
	,database_name
	,sessao_bloqueada
	,sessao_bloqueadora
	,start_time
	,comando
	,handle_id
	,tipo
	,hostname
	,program_name
	)
AS (
	SELECT database_id
		,db_name(database_id) AS 'ndatabase'
		,session_id AS 'sessao_bloqueada'
		,blocking_session_id AS 'sessao_bloqueadora'
		,start_time AS 'Start_Time'
		,command AS 'comando'
		,er.sql_handle AS 'handle_id'
		,wait_type AS 'tipo'
		,SYP.hostname
		,SYP.program_name
	FROM sys.dm_exec_requests AS ER
	INNER JOIN SYS.sysprocesses AS SYP ON ER.session_id = SYP.spid
	WHERE blocking_session_id <> 0
	)

SELECT database_name
	,sessao_bloqueada
	,sessao_bloqueadora
	,start_time
	,comando
	,hostname
	,c.program_name
	,substring(texto_bloqueado.TEXT,1,100) AS 'Query Bloqueada'
	,substring(texto_bloqueador.TEXT,1,100) AS 'Query Bloqueadora'
	,DATEDIFF(SS, start_time, GETDATE()) AS 'Tempo Bloqueio Segundos'
FROM cte_sessoes c
INNER JOIN sys.databases sd ON c.database_id = sd.database_id
INNER JOIN sys.dm_exec_connections sdc ON c.sessao_bloqueadora = sdc.session_id
INNER JOIN sys.dm_exec_sessions sec ON c.sessao_bloqueada = sec.session_id
CROSS APPLY sys.dm_exec_sql_text(c.handle_id) AS texto_bloqueado
CROSS APPLY sys.dm_exec_sql_text(sdc.most_recent_sql_handle) AS texto_bloqueador

--Verificar maior bloqueador

SELECT blocking_session_id AS Sessao
	,COUNT(session_id) AS TotalBloqueios
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0
GROUP BY blocking_session_id
ORDER BY TotalBloqueios DESC
	-- Lock em cadeia
	;

WITH Sessoes (
	Sessao
	,Bloqueadora
	)
AS (
	SELECT Session_Id
		,Blocking_Session_Id
	FROM sys.dm_exec_requests AS R
	WHERE blocking_session_id > 0
	
	UNION ALL
	
	SELECT Session_Id
		,CAST(0 AS SMALLINT)
	FROM sys.dm_exec_sessions AS S
	WHERE EXISTS (
			SELECT *
			FROM sys.dm_exec_requests AS R
			WHERE S.Session_Id = R.Blocking_Session_Id
			)
		AND NOT EXISTS (
			SELECT *
			FROM sys.dm_exec_requests AS R
			WHERE S.Session_Id = R.Session_Id
			)
	)
	,Bloqueios
AS (
	SELECT CAST(Sessao AS VARCHAR(200)) AS Cadeia_Bloqueio
		,Sessao
		,Bloqueadora
		,1 AS Nivel
	FROM Sessoes
	
	UNION ALL
	
	SELECT CAST(B.Cadeia_Bloqueio + ' -> ' + CAST(S.Sessao AS VARCHAR(5)) AS VARCHAR(200))
		,S.Sessao
		,B.Sessao
		,Nivel + 1
	FROM Bloqueios AS B
	INNER JOIN Sessoes AS S ON B.Sessao = S.Bloqueadora
	)

SELECT Cadeia_Bloqueio
FROM Bloqueios
WHERE Nivel = (
		SELECT MAX(Nivel)
		FROM Bloqueios
		)
ORDER BY Cadeia_Bloqueio
GO


SELECT
    session_id,
    start_time, 
    [status],
    command,
    blocking_session_id,
    wait_type,
    wait_time,
    open_transaction_count,
    transaction_id,
    total_elapsed_time,
    Definition = CAST(text AS VARCHAR(MAX))
FROM
    SYS.DM_EXEC_REQUESTS
    CROSS APPLY sys.dm_exec_sql_text(sql_handle) 
WHERE blocking_session_id != 0

EXEC sp_whoisActive;

--- Retorna o comando que está sendo executado no ID da sessão.
SELECT c.session_id, c.properties, c.creation_time, c.is_open, t.text
FROM sys.dm_exec_cursors (306) c --0 for all cursors running
CROSS APPLY sys.dm_exec_sql_text (c.sql_handle) t


 

SELECT value
FROM sys.configurations
WHERE name = 'cost threshold for parallelism'