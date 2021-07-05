
DECLARE  @login sysname
DECLARE  @db sysname

DECLARE Cont CURSOR FOR
	select name from sys.sysusers
OPEN cont;	
FETCH NEXT FROM Cont into @login

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		DECLARE dbt CURSOR FOR
			select name from sys.sysdatabases where dbid > 4
		OPEN dbt;	
		FETCH NEXT FROM dbt into @db
			WHILE @@FETCH_STATUS = 0 
			BEGIN
				declare @SqlCommand nvarchar(4000)
		
				set @SqlCommand = 'USE '+ @db  +'
EXEC sp_change_users_login ''auto_fix'', '''+ @login +''' '

				 print @SqlCommand

				 --exec sp_executesql SqlCommand

				FETCH NEXT FROM dbt into @db				
			END;          
		CLOSE dbt
		DEALLOCATE dbt
		FETCH NEXT FROM Cont into @login				
	END;       
CLOSE Cont
DEALLOCATE Cont