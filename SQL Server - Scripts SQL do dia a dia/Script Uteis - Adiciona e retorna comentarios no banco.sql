
-- Retorna a descrição dos objetos.
SELECT 
    major_id, minor_id, 
	ep.name,
    t.name AS [Table Name], 
    c.name AS [Column Name], 
    value AS [Extended Property]
FROM 
    sys.extended_properties AS ep
LEFT JOIN 
    sys.tables AS t ON ep.major_id = t.object_id 
LEFT JOIN 
    sys.columns AS c ON ep.major_id = c.object_id 
                     AND ep.minor_id = c.column_id
WHERE 
    class = 1
    AND ep.name = 'MS_Description'


USE [inventario]
GO

GO
EXEC sys.sp_updateextendedproperty @name=N'MS_Description', @value=N'Tabelas com o cruzamento dos hosts de diferentes fonte de dados' , @level0type=N'SCHEMA',@level0name=N'ServerHost', @level1type=N'TABLE',@level1name=N'Servidor'

GO
