#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
 CREATE USER metabase WITH PASSWORD 'metabase';
 CREATE DATABASE metabase;
 GRANT ALL PRIVILEGES ON DATABASE metabase TO metabase;

 \c metabase

 \pset tuples_only
 \o /tmp/grant-privs
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "' || schemaname || '"."' || tablename || '" TO metabase ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
 \o
 \i /tmp/grant-privs

EOSQL