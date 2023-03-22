ALTER DATABASE pje_teste SET search_path TO client, core, jt, criminal, public, acl;



SELECT r.rolname, d.datname, rs.setconfig
FROM   pg_db_role_setting rs
LEFT   JOIN pg_roles      r ON r.oid = rs.setrole
LEFT   JOIN pg_database   d ON d.oid = rs.setdatabase