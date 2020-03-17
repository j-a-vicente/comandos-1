SELECT
    db_name(database_id) as BaseDeDados,
    last_user_seek as 'Hora da última busca de usuário.', 
    last_user_scan as 'Hora do último exame de usuário.', 
    last_user_lookup as 'Hora da última pesquisa de usuário.', 
    last_user_update as 'Hora de última atualização de usuário.'
FROM sys.dm_db_index_usage_stats  
