CREATE TABLE #Table(
        SPID INT,
        Status VARCHAR(255),
        LOGIN VARCHAR(255),
        HostName VARCHAR(255),
        BlkBy VARCHAR(255),
        DBName VARCHAR(255),
        Command VARCHAR(255),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(255),
        ProgramName VARCHAR(255),
        SPID_1 INT 
)

CREATE TABLE #Inputbuffer(
EventType NVARCHAR(30) NULL,
Parameters INT NULL,
EventInfo NVARCHAR(255) NULL
)

CREATE TABLE #result(
        SPID INT,
        Status VARCHAR(255),
        LOGIN VARCHAR(255),
        HostName VARCHAR(255),
        BlkBy VARCHAR(255),
        DBName VARCHAR(255),
        Command VARCHAR(255),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(255),
        ProgramName VARCHAR(255),
        SPID_1 INT ,
        commandeDesc  VARCHAR(255)
)


	INSERT INTO #Table EXEC sp_who2


DECLARE  @SPID INT
DECLARE  @BlkBy nchar(255)
DECLARE  @Script nchar(255)
DECLARE  @commandeDesc nchar(255)

	DECLARE Cont CURSOR FOR

		SELECT SPID, BlkBy
		FROM    #Table
		WHERE  --status ='RUNNABLE' and 
			   DATEDIFF (MI, (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) >= 5
			   --and BlkBy <> '  .  '
		order by CPUTime DESC

	OPEN cont;	

FETCH NEXT FROM Cont into @SPID, @BlkBy

WHILE @@FETCH_STATUS = 0 
	BEGIN
          
		INSERT #Inputbuffer
		EXEC ('dbcc inputbuffer (' + @spid + ')')

		SELECT @commandeDesc = EventInfo FROM #Inputbuffer

		INSERT INTO #result (SPID, Status, LOGIN, HostName, BlkBy , DBName, Command, CPUTime, DiskIO, LastBatch, ProgramName, SPID_1, commandeDesc)
		SELECT SPID, Status, LOGIN, HostName, BlkBy , DBName, Command, CPUTime, DiskIO, LastBatch, ProgramName, SPID_1, @commandeDesc
		FROM    #Table		
		WHERE SPID = @SPID AND BlkBy = @BlkBy AND DBname <> 'master'	
		
		delete from #Inputbuffer
		
		FETCH NEXT FROM Cont into @SPID, @BlkBy
				
	END;


SELECT 
        SPID,
        BlkBy,
        CPUTime,
        DiskIO,
        DATEDIFF (MI, (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) )'ProcParadoMi', 
        (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) 'start date' , 
        Status,
        LOGIN,
        HostName,        
        DBName,
        Command,
        ProgramName,
        commandeDesc
FROM #result
ORDER BY DATEDIFF (MI, (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) DESC

CLOSE Cont;
DEALLOCATE Cont;

DROP TABLE #Inputbuffer
GO

DROP TABLE #Table
GO

DROP TABLE #result
GO