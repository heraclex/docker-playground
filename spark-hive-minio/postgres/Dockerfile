FROM postgres:13

# Copy postgres config file into container
# COPY postgresql.conf /etc/postgresql

# Override default postgres config file
# CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

# ADD hive-schema-3.1.0.postgres.sql /hive/hive-schema-3.1.0.postgres.sql
ADD init-metastore-db.sh /docker-entrypoint-initdb.d/init-metastore-db.sh
ADD init-datastore-db.sh /docker-entrypoint-initdb.d/init-datastore-db.sh
ADD init-airflow-db.sh /docker-entrypoint-initdb.d/init-airflow-db.sh
ADD init-metabase-db.sh /docker-entrypoint-initdb.d/init-metabase-db.sh
ADD init-superset-db.sh /docker-entrypoint-initdb.d/init-superset-db.sh

# adding datastore for spark app
ADD datastore.sql /datastore.sql

EXPOSE 5432
