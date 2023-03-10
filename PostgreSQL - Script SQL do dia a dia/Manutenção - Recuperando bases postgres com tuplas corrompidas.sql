/*
PROBLEMA

Durante o backup de um banco ocorre:

pg_dump: Cópia do conteúdo da tabela "TABELA_EXEMPLO" falhou: PQgetResult() falhou.
pg_dump: Mensagem de erro do servidor: ERRO: compressed data is corrupt
pg_dump: O comando foi: COPY public.exemplo (id, dado1, dado2, dado3) TO stdout;
EXPLICAÇÃO DO PROBLEMA

As colunas das tabelas do postgres são salvas em HD: no modo "compactado/extended" (text + character + qualquer vetor, por padrão) OU no modo "plano/plain" (todos os outros tipos de dados, por padrão)
Uma coluna compactada no HD é descompactada automaticamente na hora em que qualquer SQL tenta obter este dado do HD
A exceção em questão se apresenta quando o postgres não consegue descompactar do HD o conteúdo comprimido que lá está salvo, significando que portanto aquele dado está corrompido
A causa do dado estar corrompido é desconhecida no nosso caso
SOLUÇÃO

Na máquina de bancos foi gerado um backup completo do "bancoCorrompido" em um "bancoCorrompido_clone" que copiou tudo, inclusive os dados corrompidos exatamente como estavam no banco original: createdb --host= --port= --username= --template=bancoCorrompido bancoCorrompido_clone
Com a ajuda das orientações do link a seguir, descobri exatamente quais as tuplas que estavam com problema, e mais especificamente (através de outros comandos adicionais, disponíveis no fim do arquivo) quais colunas destas tuplas que eram o problema de fato. http://no0p.github.io/postgresql/2013/04/02/postgres-corruption-resolution.html
Atualizei estas tuplas atribuindo valores nulos (null / '' / 0)
Dessa forma a tupla corrompida continua existindo no banco com todos os outros dados, apenas perdendo realmente o dado substituído, uma vez que já está perdido/corrompido de qualquer forma.
O "bancoCorrompido_clone" gerado antes da correção tem o único propósito de existir na máquina de bancos.
Se um dia alguém precisar do conteúdo deste dado substituído, e conseguir descobrir uma forma de recuperar um dado corrompido do postgres, ainda teremos o "bancoCorrompido_clone" disponível no postgres para poder tentar recuperar esta informação e a atribuirmos de volta ao real banco
Aproveite a correção e gere imediatamente backups manuais para o banco, confirmando que eles não está mais corrompido
COMANDOS QUE UTILIZEI NA SOLUÇÃO:*/

-- CRIA A FUNÇÃO DE CHECAGEM
create function chk(anyelement)
   returns bool
language plpgsql as $f$
    declare t text;
    begin t := $1;
      return false;
      exception when others then return true;
    end;
  $f$;

-- DESCOBRE O ID DAS TUPLAS COM PROBLEMA
select id from TABELA_EXEMPLO where chk(TABELA_EXEMPLO);

-- TENTA OBTER TODOS OS DADOS DA TUPLA 1 - DEVE LANÇAR A EXCEÇÃO DE DADOS CORROMPIDOS
select * from TABELA_EXEMPLO where id = <retornoDaSqlDaFuncao>;
select id, dado1, dado2, dado3 from TABELA_EXEMPLO where id = <retornoDaSqlAnterior>;

-- TENTA OBTER TODOS OS DADOS DA TUPLA 1 EXCLUINDO-SE A COLUNA QUE SE ESPERA ESTAR CORROMPIDA
-- (dado2 por exemplo) - DEVE FUNCIONAR COM SUCESSO, PROVANDO QUE A COLUNA QUE NÃO FOI PEDIDA
-- NA CONSULTA DE FATO É A QUE ESTAVA CORROMPIDA
select id,dado1,dado3 from TABELA_EXEMPLO where id = <retornoDaSqlDaFuncao>;

-- ANULA O CONTEÚDO DA COLUNA CORROMPIDA DA TUPLA 1 COM PROBLEMA
update TABELA_EXEMPLO set dado2 = null where id = <retornoDaSqlDaFuncao>;

-- REMOVE A FUNÇÃO DE CHECAGEM
drop function chk(anyelement);