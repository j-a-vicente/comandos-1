SELECT
    db_name(database_id) as BaseDeDados,
    last_user_seek as 'Hora da �ltima busca de usu�rio.', 
    last_user_scan as 'Hora do �ltimo exame de usu�rio.', 
    last_user_lookup as 'Hora da �ltima pesquisa de usu�rio.', 
    last_user_update as 'Hora de �ltima atualiza��o de usu�rio.'
FROM sys.dm_db_index_usage_stats  
