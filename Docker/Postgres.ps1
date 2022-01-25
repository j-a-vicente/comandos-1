

#Baixa a IMAGEM do PostgreSQL.
docker pull postgres

<#Para instalar uma versão especifica utilize as TAG:
14.1, 14, latest, 14.1-bullseye, 14-bullseye, bullseye
14.1-alpine, 14-alpine, alpine, 14.1-alpine3.15, 14-alpine3.15, alpine3.15
13.5, 13, 13.5-bullseye, 13-bullseye
13.5-alpine, 13-alpine, 13.5-alpine3.15, 13-alpine3.15
12.9, 12, 12.9-bullseye, 12-bullseye
12.9-alpine, 12-alpine, 12.9-alpine3.15, 12-alpine3.15
11.14-bullseye, 11-bullseye
11.14, 11, 11.14-stretch, 11-stretch
11.14-alpine, 11-alpine, 11.14-alpine3.15, 11-alpine3.15
10.19-bullseye, 10-bullseye
10.19, 10, 10.19-stretch, 10-stretch
10.19-alpine, 10-alpine, 10.19-alpine3.15, 10-alpine3.15
9.6.24-bullseye, 9.6-bullseye, 9-bullseye
9.6.24, 9.6, 9, 9.6.24-stretch, 9.6-stretch, 9-stretch
9.6.24-alpine, 9.6-alpine, 9-alpine, 9.6.24-alpine3.15, 9.6-alpine3.15, 9-alpine3.15
Exemplo:#>
docker pull postgres:11.14

#Verificar se a imagem foi baixada com sucesso execute o comando abaixo:
docker images


#Para executar a imagem baixa e transformar em um container execute o comando abaixo:
docker run -p 5432:5432 -e POSTGRES_PASSWORD=1234 postgres

<#
Para uma container personalizado é preciso utilizar as variáveis de ambiente.
Segue as variáveis e sua descrição:

POSTGRES_PASSWORD
Essa variável de ambiente é necessária para você usar a imagem do PostgreSQL. Não deve ser vazio ou indefinido. Essa variável de ambiente define a senha do superusuário para o PostgreSQL. O superusuário padrão é definido pela POSTGRES_USERvariável de ambiente.

Nota 1: A imagem do PostgreSQL configura a trustautenticação localmente, então você pode notar que uma senha não é necessária ao conectar de localhost(dentro do mesmo container). No entanto, uma senha será necessária se conectar de um host/contêiner diferente.

Nota 2: Esta variável define a senha do superusuário na instância do PostgreSQL, conforme definido pelo initdbscript durante a inicialização do contêiner. Não tem efeito na PGPASSWORDvariável de ambiente que pode ser usada pelo psqlcliente em tempo de execução, conforme descrito em https://www.postgresql.org/docs/current/libpq-envars.html . PGPASSWORD, se usado, será especificado como uma variável de ambiente separada.

POSTGRES_USER
Essa variável de ambiente opcional é usada em conjunto com POSTGRES_PASSWORDpara definir um usuário e sua senha. Essa variável criará o usuário especificado com poder de superusuário e um banco de dados com o mesmo nome. Se não for especificado, o usuário padrão de postgresserá usado.

Esteja ciente de que, se este parâmetro for especificado, o PostgreSQL ainda será exibido The files belonging to this database system will be owned by user "postgres"durante a inicialização. Isso se refere ao usuário do sistema Linux (da /etc/passwdimagem) que o postgresdaemon executa e, como tal, não está relacionado à POSTGRES_USERopção. Consulte a seção intitulada " --userNotas Arbitrárias" para obter mais detalhes.

POSTGRES_DB
Essa variável de ambiente opcional pode ser usada para definir um nome diferente para o banco de dados padrão que é criado quando a imagem é iniciada pela primeira vez. Se não for especificado, o valor de POSTGRES_USERserá usado.

POSTGRES_INITDB_ARGS
Essa variável de ambiente opcional pode ser usada para enviar argumentos para postgres initdb. O valor é uma sequência de argumentos separada por espaços, como postgres initdbseria de esperar. Isso é útil para adicionar funcionalidades como somas de verificação de página de dados: -e POSTGRES_INITDB_ARGS="--data-checksums".

POSTGRES_INITDB_WALDIR
Essa variável de ambiente opcional pode ser usada para definir outro local para o log de transações do Postgres. Por padrão, o log de transações é armazenado em um subdiretório da pasta de dados principal do Postgres ( PGDATA). Às vezes, pode ser desejável armazenar o log de transações em um diretório diferente que pode ser apoiado por armazenamento com características de desempenho ou confiabilidade diferentes.

Nota: no PostgreSQL 9.x, esta variável é POSTGRES_INITDB_XLOGDIR(refletindo o nome alterado do --xlogdirsinalizador para --waldirno PostgreSQL 10+ ).

POSTGRES_HOST_AUTH_METHOD
Essa variável opcional pode ser usada para controlar as conexões para auth-methodbancos de dados, usuários e endereços. Se não for especificado, a autenticação de senha será usada. Em um banco de dados não inicializado, isso será preenchido por meio desta linha aproximada:hostallallallmd5pg_hba.conf

echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> pg_hba.conf
Consulte a documentação do PostgreSQL pg_hba.confpara obter mais informações sobre valores possíveis e seus significados.

PGDATA
Esta variável opcional pode ser usada para definir outro local - como um subdiretório - para os arquivos do banco de dados. O padrão é /var/lib/postgresql/data. Se o volume de dados que você está usando é um ponto de montagem do sistema de arquivos (como nos discos permanentes GCE) ou uma pasta remota que não pode ser atribuída ao postgresusuário (como algumas montagens NFS), o Postgres initdbrecomenda que um subdiretório seja criado para conter os dados.

Por exemplo:

$ docker run -d \
    --name some-postgres \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /custom/mount:/var/lib/postgresql/data \
    postgres
#>

#Criar um container direcionando o local para amarzenar o banco de dados, como um disco ou um nfs
docker run -p 5432:5432 -v /tmp/database:/var/lib/postgresql/data -e POSTGRES_PASSWORD=1234 postgres
# O paramentro "-v" indica o local onde será armazernado o  banco de dados.

#Execute o comando abaixo para verificar se o container está em execução:
docker ps 

#Para ver todos os container execute com o -all
docker ps -all