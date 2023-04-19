#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
 CREATE USER sparkapp WITH PASSWORD 'sparkapp';
 CREATE DATABASE sparkapp;
 GRANT ALL PRIVILEGES ON DATABASE sparkapp TO sparkapp;
 \c sparkapp
 \i /datastore.sql
EOSQL

