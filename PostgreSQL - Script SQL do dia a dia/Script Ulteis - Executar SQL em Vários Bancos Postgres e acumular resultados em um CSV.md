SENHA_POSTGRES='<senha-postgres>'
USUARIO_POSTGRES='<usuario-postgres>'
LISTA_NOMES_BANCOS='banco1 banco2 banco3'
COMANDO="SELECT * FROM tabela"
ARQUIVO=saida.csv

echo '' > $ARQUIVO
for NOME_BANCO in $LISTA_NOMES_BANCOS ; do
        echo 'Executando consultas no banco '  $NOME_BANCO
        PGPASSWORD=$SENHA_POSTGRES psql -h localhost -d $NOME_BANCO -U $USUARIO_POSTGRES -c "$COMANDO" -F ';' -A -t >> $ARQUIVO
done
