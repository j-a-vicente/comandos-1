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

INSERT INTO #Table EXEC sp_who2

SELECT  (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) 'date' , 
        DATEDIFF (MI, (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) )'ProcParadoMi' ,
        *
FROM    #Table
--WHERE   
       --status ='RUNNABLE' 
       --AND
       --DATEDIFF (MI, (left(LastBatch, 5)+'/2013 ' + RIGHT(LastBatch,8) ) ,CONVERT(datetime, GETDATE(),121) ) >= 5
order by CPUTime DESC

DROP TABLE #Table
GO