select
    nome_tabela = object_name(b.object_id),
    nome_indice = name, 
    fragmentacao_media = avg_fragmentation_in_percent,
    script = case
        when avg_fragmentation_in_percent > 30 then 'alter index ' + name + ' on ' + object_name(b.object_id) + ' rebuild with (online = on)'
        when avg_fragmentation_in_percent >= 5 and avg_fragmentation_in_percent <= 30 then 'alter index ' + name + ' on ' + object_name(b.object_id) + ' reorganize'
    end
from sys.dm_db_index_physical_stats (db_id('curso'), null, null, null, null) as a -- (Parâmetros da função: banco de dados, tabela, indice, partição física, modo de analise: default, null, limited (limitado), sampled (amostra), detailed (detalhado))
join sys.indexes as b on a.object_id = b.object_id and a.index_id = b.index_id
order by avg_fragmentation_in_percent desc