#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
 CREATE USER shopback WITH PASSWORD 'shopback';
 CREATE DATABASE shopback;
 GRANT ALL PRIVILEGES ON DATABASE shopback TO shopback;
 \c shopback
 \i /hive/datastore.sql
EOSQL

