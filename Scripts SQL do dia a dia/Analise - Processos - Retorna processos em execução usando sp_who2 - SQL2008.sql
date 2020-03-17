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
        LastBatch VARCHAR(MAX),
        ProgramName VARCHAR(MAX),
        SPID_1 INT,
        REQUESTID INT
)

INSERT INTO @Table EXEC sp_who2

SELECT  (left(LastBatch, 5)+'/2014 ' + RIGHT(LastBatch,8) ) 'date' , 
        DATEDIFF (MI, (left(LastBatch, 5)+'/2014 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) as 'TempoParadoMi' ,
        *
FROM    @Table
--WHERE  
	   --HostName = 'SBRPWCYD01DB09' or SPID = 295
	   --status ='RUNNABLE' 
	   --AND
       --DATEDIFF (MI, (left(LastBatch, 5)+'/2014 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) >= 15
       --AND 
       ---SPID >= 51*/
order by DATEDIFF (MI, (left(LastBatch, 5)+'/2014 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) DESC