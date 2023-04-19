#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
 CREATE USER superset WITH PASSWORD 'superset';
 CREATE DATABASE superset;
 GRANT ALL PRIVILEGES ON DATABASE superset TO superset;

 \c superset

 \pset tuples_only
 \o /tmp/grant-privs
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "' || schemaname || '"."' || tablename || '" TO superset ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
 \o
 \i /tmp/grant-privs

EOSQL