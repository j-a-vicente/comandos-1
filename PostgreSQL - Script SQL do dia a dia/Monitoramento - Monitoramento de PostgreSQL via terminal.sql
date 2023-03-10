/*
Extremamente útil para quem vive sofrendo com o pgAdmin travando.
Desenvolvida em python, a aplicação pg_activity disponibiliza uma interface parecida com o top.
Para instalar basta fazer o clone do projeto em qualquer lugar:
git clone https://github.com/julmon/pg_activity.git
cd pg_activity
--Ou se preferir, fazer o download do repositorio:

wget https://github.com/julmon/pg_activity/archive/master.zip -O pg_activity.zip
unzip pg_activity.zip
cd pg_activity-master
A instalação depende do python ≥ 2.6 (normalmente você já deve ter na sua distribuição do linux). Para verificar rode python --version. Caso não tenha, para instalar no Ubuntu basta rodar: sudo apt-get install python
Instale também os pacotes python que são requisitos:

sudo apt-get install python-psycopg2 python-psutil python-setuptools
--Em seguida execute a instalação através do código fonte (verifique se você está no diretório do projeto):

sudo python setup.py install --with-man
Pronto.
Agora para monitorar o seu postgres local basta rodar (não precisa mais estar no diretório do projeto):

sudo -u postgres pg_activity -U postgres
--Ou para monitorar um servidor postgres remoto:

PGPASSWORD='<senha do usuário>' pg_activity -U <usuário remoto> -h <host remoto>
Para mais instruções de uso leia o README do projeto.
https://github.com/julmon/pg_activity*/