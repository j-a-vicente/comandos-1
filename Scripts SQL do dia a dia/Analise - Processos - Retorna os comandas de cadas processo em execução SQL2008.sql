----Receber o processos com mas de 15 minutos em aberto.
DECLARE @Table TABLE(
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        login_time VARCHAR(MAX),
        ProgramName VARCHAR(MAX)
)

DECLARE @Inputbuffer TABLE(
		EventType VARCHAR(30),
		Parameters INT,
		EventInfo VARCHAR(255) 
)

DECLARE @result TABLE(
        SPID INT,
        Status VARCHAR(MAX),
        LOGIN VARCHAR(MAX),
        HostName VARCHAR(MAX),
        BlkBy VARCHAR(MAX),
        DBName VARCHAR(MAX),
        Command VARCHAR(MAX),
        CPUTime INT,
        DiskIO INT,
        login_time VARCHAR(MAX),
        ProgramName VARCHAR(MAX),
        commandeDesc  VARCHAR(MAX)
)

INSERT INTO @Table
select /* DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) as tempo,*/
      SPID,
      STATUS,
      LOGINAME,
      HOSTNAME,
      BLOCKED,
      DB_NAME(dbid),
      CMD,
      CPU,
      PHYSICAL_IO,
      login_time,
      program_name
from sysprocesses
where 
blocked <> 0
--AND
--LOGINAME like '%PRD_OT_WEMSYS%'
--AND
--DB_NAME(dbid) = 'Biztalk_integracao'
--AND     
--DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) >= 15          

DECLARE  @SPID INT
DECLARE  @BlkBy nchar(255)
DECLARE  @Script nchar(255)
DECLARE  @commandeDesc nchar(255)

	DECLARE Cont CURSOR FOR

		SELECT SPID, BlkBy
		FROM    @Table

	OPEN cont;	

FETCH NEXT FROM Cont into @SPID, @BlkBy		

WHILE @@FETCH_STATUS = 0 
	BEGIN
          
		INSERT @Inputbuffer
		EXEC ('dbcc inputbuffer (' + @spid + ')')

		SELECT @commandeDesc = EventInfo FROM @Inputbuffer

		INSERT INTO @result (SPID, Status, LOGIN, HostName, BlkBy , DBName, Command, CPUTime, DiskIO, login_time, ProgramName, commandeDesc)
		SELECT SPID, Status, LOGIN, HostName, BlkBy , DBName, Command, CPUTime, DiskIO, login_time, ProgramName,  @commandeDesc
		FROM    @Table		
		WHERE SPID = @SPID AND BlkBy = @BlkBy		
		
		delete from @Inputbuffer
		
		FETCH NEXT FROM Cont into @SPID, @BlkBy
				
	END;		
	
SELECT DBName,
       DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) AS 'Tempo parado',
       SPID,
       Status,
       LOGIN,
       HostName,
       BlkBy,
       Command,
       CPUTime,
       DiskIO,
       login_time,
       ProgramName,
       commandeDesc       
FROM @result	
ORDER BY SPID, DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) DESC
	
CLOSE Cont;
DEALLOCATE Cont;	