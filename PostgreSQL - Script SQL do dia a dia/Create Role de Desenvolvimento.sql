CREATE ROLE roledesenvolvedor WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	CREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
COMMENT ON ROLE roledesenvolvedor IS 'Está Role é para o usuários que deverão ter acesso de desenvolvimento nas bases de dados do servidor.
O acesso deste grupo é de db_owner.';