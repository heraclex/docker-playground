FROM postgres:13

# Copy postgres config file into container
# COPY postgresql.conf /etc/postgresql

# Override default postgres config file
# CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

# ADD hive-schema-3.1.0.postgres.sql /hive/hive-schema-3.1.0.postgres.sql
ADD init-metastore-db.sh /docker-entrypoint-initdb.d/init-metastore-db.sh

ADD datastore.sql /datastore.sql
ADD init-datastore-db.sh /docker-entrypoint-initdb.d/init-datastore-db.sh

EXPOSE 5432
