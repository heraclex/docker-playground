FROM postgres:13

MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

# Copy postgres config file into container
COPY postgresql.conf /etc/postgresql

# Override default postgres config file
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

ADD hive-schema-3.1.0.postgres.sql /hive/hive-schema-3.1.0.postgres.sql
ADD datastore.sql /hive/datastore.sql
# ADD hive-txn-schema-2.3.0.postgres.sql /hive/hive-txn-schema-2.3.0.postgres.sql

ADD init-hive-db.sh /docker-entrypoint-initdb.d/init-user-db.sh
ADD init-datastore-db.sh /docker-entrypoint-initdb.d/init-datastore-db.sh

EXPOSE 5432
