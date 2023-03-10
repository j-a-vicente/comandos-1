Executar scripts e exportar csv usando SQL*Plus
Posted almost 7 years ago. Visible to the public.
Às vezes temos acesso à um servidor oracle apenas via linha de comando. Nesses casos é útil saber como executar scripts em arquivos externos ou exportar os dados usando o SQL*Plus

Para se conectar ao banco rode:

sqlplus64 [username]/[password]@[host]:[port]/[service_name]
Conectado ao SQL*Plus você pode realizar consultas normalmente:

SQL> SELECT 1 FROM DUAL;
Rodar script externo
Caso queira executar uma consulta maior o ideal, é escreve-la em um arquivo e executar o script, basta rodar de dentro do sqlplus:

SQL> @filename.sql;
Onde "filename.sql" é o arquivo salvo.

Exportar csv
Para exportar csv, não existe uma forma prática, mas podemos configurar o sqlplus para dar seu output padrão em um arquivo. Mas antes adaptar a forma como ele escreverá:

alter session set nls_timestamp_format='dd/mm/yyyy HH24:mi:ss';
alter session set nls_date_format='dd/mm/yyyy HH24:mi:ss';

set colsep ';'     -- Configura o separador de colunas como sendo ';'
set pagesize 0     -- Remove os cabeçalhos
set trimspool on   -- Remove os espaços em branco inseridos pelo sqlplus
set linesize X     -- Tamanho máximo que terá sua linha
set wrap off       -- Desabilita a quebra de linha. Cuidado pode cortar se for maior que linesize

spool output.csv   -- Configura o arquivo que será escrito