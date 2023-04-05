/*************************************************************************************************************************************
SQL Server: Monitorando o uso do disco

O desempenho do Microsoft SQL Server depende muito do subsistema de E/S (IOS). 
A latência no IOS pode resultar em muitos problemas de desempenho. Por exemplo, você pode enfrentar tempos de resposta 
lentos e problemas causados pelo tempo limite das tarefas. É fundamental que você monitorar o uso do disco.
Monitorando E/S de disco
Contadores de disco que você pode monitorar para determinar a atividade do disco são divididos nos dois grupos a seguir:

Primário
    PhysicalDisk: Média de disco seg/gravação
    PhysicalDisk: Média de disco seg/leitura

Secundário
    PhysicalDisk: Comprimento médio da fila de disco
    PhysicalDisk: Bytes de disco/s
    PhysicalDisk: Transferências de disco/s

Cada disco deve ser monitorado individualmente. Observe que o uso da instância (_Total) pode ser enganoso e mascarar áreas problemáticas. 
Isso ocorre porque a instância (_Total) soma e calcula a média de todos os discos juntos.

Observação : se você estiver usando pontos de montagem, recomendamos que você use o objeto de disco lógico em vez do objeto de disco físico. 
O Disco Lógico exibe o caminho do ponto de montagem em vez do caminho físico número da unidade.


Primário - PhysicalDisk

        No Monitor do Sistema, os contadores Média de Disco seg/Gravação e Média de Disco seg/Leitura são considerados "primários". 
        Esses contadores devem ser examinados primeiro e não precisam de informações adicionais para avaliar o desempenho da unidade. 
        Estes os contadores determinam a latência média de uma solicitação de E/S.

        Média de Disco Seg/Leitura é o tempo médio em segundos de uma leitura de dados do disco. A lista a seguir mostra intervalos de valores possíveis e 
    o que os intervalos representam:

        + Menos de 10 ms - muito bom
        + Entre 10 - 20 ms - ok
        + Entre 20 - 50 ms - lento, precisa de atenção
        + Maior que 50 ms – Gargalo de E/S grave

    Média de Disco Se/Gravação é o tempo médio em segundos de uma gravação de dados no disco. 
    As diretrizes para os valores médios de Disco Seg/Leitura se aplicam aqui.

    Observação : os números listados nesta seção são para referência geral. Se você tiver um requisito muito alto de tempo de
    resposta do aplicativo em um sistema ocupado, atender ao tempo de resposta do disco com esses números pode não ser suficiente.

    Se todos ou a maioria dos drives relatarem alta latência, o afunilamento provavelmente estará no meio de 
    comunicação (como HBA SAN, switches, fibra, CPUs do adaptador front-end e cache). Se apenas uma unidade ou algumas poucas relatarem latência, 
    o afunilamento geralmente estar no JBOD (número de discos). Para examinar melhor isso, revise os contadores secundários para as unidades 
    que relatam alta latência. Se todas as unidades estiverem abaixo de seu limite, não há razão para examinar os contadores secundários.

    Observação : no Monitor do sistema, é importante monitorar usando o campo máximo. Usar o campo médio no Monitor do Sistema pode ser enganoso.

Secundário

    Você só deve usar os contadores secundários para a(s) unidade(s) que têm alta latência. Se a unidade tiver latência aceitável, 
    não faz sentido avançar. Bytes de disco/s e transferências de disco/s são usados para determinar o tamanho e o número de solicitações de E/S. 
    Esses contadores podem ajudar a determinar se o número de discos ou o meio de comunicação é a fonte da latência. É possível também use o 
    comprimento médio da fila de disco para validar o meio de comunicação. Geralmente, um valor maior que 32 representa um gargalo que pode aumentar a 
    latência.

    As Transferências de Disco/s são compostas por Leituras de Disco/s e Gravações de Disco/seg. Você pode usar esses contadores para determinar 
    se a unidade não tem discos de suporte suficientes. Ao usar esses contadores, talvez seja necessário ajustar os valores para o tipo de RAID 
    implementado. Para determinar quais valores para usar, use as seguintes fórmulas:

        +Raid 0 -- E/S por disco = (leituras + gravações) / número de discos
        +Raid 1 -- E/S por disco = [leituras + (2 * gravações)] / 2
        +Raid 5 -- E/S por disco = [leituras + (4 * gravações)] / número de discos
        +Raid 10 -- E/S por disco = [leituras + (2 * gravações)] / número de discos

    Por exemplo, se o valor máximo para Transferências de disco/s for 1800, você poderá determinar que a unidade precisará de pelo menos 10 discos 
    de 15 k RPM em seu grupo RAID. Geralmente, um disco de 15k RPM é capaz de aproximadamente 180 solicitações de E/S por segundo (IOPS). 180*10 = 1800. 
    Para um valor mais alto, você pode precisar de mais de 10 discos.

    NOTA: Consulte o fornecedor de hardware para identificar a quantidade exata de IOPS que seus discos são capazes de manipular. 
    O tempo médio de busca e a latência rotacional podem afetar a saída da IOPS. Todos os discos NÃO são criados iguais.


Latência
    Se a latência for consistentemente alta, você poderá determinar a causa raiz usando os contadores secundários. 
    Se a latência for devida ao número de discos, considere o seguinte:

        + Use uma unidade de disco mais rápida.
        + Mova os arquivos acessados com frequência para um disco, servidor ou SAN separados.
        + Adicione discos a uma matriz RAID se estiver usando uma.
        + Use um tipo de RAID mais rápido, como RAID 10.
        + Pare de compartilhar discos com outros volumes ou LUNs.
    Se a latência for devida ao meio de comunicação, considere o seguinte:

        + Aumente a profundidade da fila.
        + Mova os arquivos acessados com frequência para um disco, servidor ou SAN separados.
        + Valide o cache de SAN.
        + Use vários caminhos.

Identificando gargalos
    As três perguntas a seguir podem ser usadas para ajudar a identificar se há um gargalo de armazenamento e onde ele provavelmente está:

    + Há latência observada? (Média de Disco Se/Leitura > 0,020 ou Média de Disco Se/Gravação > 0,020)
    + É a latência observada em todos (a maioria) dos discos (LUNs) ou apenas em um único (poucos) discos (LUN).
        + Essa pergunta nos ajuda a entender se o problema está se inclinando para uma falta geral de comunicação entre o servidor e o armazenamento ou se o problema é mais provável devido a limitações dos fusos físicos.
        + Se a maioria dos discos for observada com latência ao mesmo tempo, isso pode indicar que a latência se deve a um afunilamento de comunicação, como: um HBA, um switch, uma porta SAN ou uma CPU SAN.
        + Se houver muitos LUNs do mesmo dispositivo de armazenamento e apenas um ou poucos forem observados com latência, o problema provavelmente se deve ao LUN.
    + Finalmente, compare a taxa de transferência do disco (Transferências de disco/s e Bytes de disco/seg) durante o tempo em que a latência foi observada com o momento em que a taxa de transferência máxima é observada.
        + Se a latência sempre cresce em proporção com a taxa de transferência, o problema pode estar nos fusos físicos; no entanto, isso não exclui a camada de comunicação. Contrate o administrador de armazenamento para identificar se os eixos físicos são capazes de lidar com a taxa de transferência observada com Transferências de Disco/s e Bytes de Disco/seg.
        + Se a latência for muito menor quando a atividade é muito maior do que o gargalo, provavelmente não é devido aos fusos físicos (JBOD). Um administrador de armazenamento deve ser contratado para auxiliar na revisão da malha de armazenamento (HBA, switches, CPU SAN, portas, ...).

Ajustando consultas
    Além dessas recomendações, considere ajustar consultas que geram grandes quantidades de E/S. Para identificar consultas que consomem grandes quantidades de E/S, use o SYS. Saltar DM_EXEC_QUERY_STATS Detran. As exibições de gerenciamento dinâmico (DMVs) têm métricas para leituras e gravações e são exibidas pela consulta. Você também pode incluir o plano de consulta e texto do comando SQL ingressando no SYS. Saltar DM_EXEC_SQL_TEXT e SYS. Saltar DM_EXEC_QUERY_PLAN funções de gerenciamento dinâmico com o operador CROSS APPLY.

    A seguir está uma consulta de exemplo usando SYS. Saltar DM_EXEC_QUERY_STATS :
*/
SELECT TOP 25
    execution_count, plan_generation_num, last_execution_time,
    total_worker_time, last_worker_time, min_worker_time, max_worker_time,
    total_logical_reads, last_logical_reads, min_logical_reads,  max_logical_reads,
    total_physical_reads, last_physical_reads, min_physical_reads,  max_physical_reads,
    total_logical_writes, last_logical_writes, min_logical_writes, max_logical_writes,
     total_elapsed_time, last_elapsed_time, min_elapsed_time, max_elapsed_time,
    (SUBSTRING(s2.text,  statement_start_offset / 2, ( (CASE WHEN statement_end_offset = -1 THEN
    (LEN(CONVERT(nvarchar(max),s2.text)) * 2) ELSE statement_end_offset END)  - statement_start_offset) / 2)  )  AS sql_statement,
        text, p.query_plan
 
FROM sys.dm_exec_query_stats qs
     CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) s2
     CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) P
ORDER BY total_physical_reads DESC
/*
Além disso, a coluna PENDING_DISK_IO_COUNT em SYS. Saltar DM_OS_SCHEDULERS pode indicar problemas no subsistema de disco. Você deve investigar melhor qualquer valor sustentado para cada processador. Você pode usar o SYS. Saltar DM_IO_PENDING_IO_REQUESTS identificar quais são as solicitações em espera e associá-las a arquivos de banco de dados. .SYS. Saltar DM_IO_VIRTUAL_FILE_STATS relata estatísticas de E/S em arquivos de dados e de log.
Outro recurso que você pode usar é o SYS. Saltar DM_OS_WAIT_STATS Detran. Use este DMV para determinar o que o mecanismo está esperando com frequência e direcionar essa área para ajuste. Você pode têm um gargalo IOS se as esperas PAGEIOLATCH representarem algumas das esperas mais altas. As esperas de PAGEIOLATCH indicam a quantidade de tempo que o mecanismo de banco de dados está aguardando o IOS. PAGEIOLATCH tem vários modos e mais esperas em PAGEIOLATCH_SH indicam uma leitura gargalo, enquanto PAGEIOLATCH_EX indica um gargalo de gravação.

Isolando a atividade de disco criada pelo SQL Server

Você pode monitorar os contadores a seguir para determinar a quantidade de E/S gerada pelos componentes do SQL Server:

    + SQL Server:Gerenciador de buffer:leituras de página/s
    + SQL Server:Gerenciador de buffer:Gravações de página/s
    + SQL Server:Gerenciador de buffer:páginas de ponto de verificação/s
    + SQL Server:Gerenciador de buffer:gravações preguiçosas/s

No Monitor do Sistema, esses contadores monitoram a quantidade de E/S gerada pelos componentes do SQL Server examinando as seguintes áreas de desempenho:

Gravando páginas em disco
Lendo páginas do disco
Se os valores desses contadores se aproximarem do limite de capacidade do subsistema de E/S de hardware, tente reduzir os valores ajustando seu aplicativo ou banco de dados para reduzir as operações de E/S (como cobertura de índice, melhores índices ou normalização), aumentando a capacidade de E/S do hardware ou a adição de memória. Por exemplo, você pode usar o Orientador de Otimização do Mecanismo de Banco de Dados para analisar cargas de trabalho típicas do SQL Server e produzir recomendações para índices, exibições indexadas e particionamento para melhorar o desempenho do servidor. Para obter mais informações sobre o Orientador de Otimização do Mecanismo de Banco de Dados, consulte Ajustando o Design de Banco de Dados Físico Jump .

Observação : esses dois contadores não incluem E/S gerada por liberações de log de transações. A maioria das E/S do log de transações são gravações. 


Referência:
https://social.technet.microsoft.com/wiki/contents/articles/3214.sql-server-monitoring-disk-usage.aspx

Ajustando o design do banco de dados físico 
https://learn.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms191531(v=sql.105)?redirectedfrom=MSDN

sys.dm_exec_query_stats (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16

sys.dm_exec_sql_text (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sql-text-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16

sys.dm_exec_query_plan (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-plan-transact-sql?redirectedfrom=MSDN&view=azuresqldb-current

sys.dm_os_schedulers (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-schedulers-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16

sys.dm_io_pending_io_requests (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-io-pending-io-requests-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16

sys.dm_io_virtual_file_stats (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-io-virtual-file-stats-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16

sys.dm_os_wait_stats (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?redirectedfrom=MSDN&view=sql-server-ver16