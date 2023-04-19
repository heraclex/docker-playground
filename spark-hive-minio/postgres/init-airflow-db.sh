#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
 CREATE USER airflow WITH PASSWORD 'airflow';
 CREATE DATABASE airflow;
 GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

 \c airflow

 \pset tuples_only
 \o /tmp/grant-privs
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "' || schemaname || '"."' || tablename || '" TO airflow ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
 \o
 \i /tmp/grant-privs
EOSQL

# \i /hive/hive-schema-3.1.0.postgres.sql

