FROM apache/superset:2.1.0
# Switching to root to install the required packages
USER root

RUN apt-get update && \
    apt-get install -y iputils-ping telnet

RUN pip install --upgrade pip

# Example: installing the MySQL driver to connect to the metadata database
# if you prefer Postgres, you may want to use `psycopg2-binary` instead
RUN pip install mysqlclient
# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/installation.html#database-dependencies
RUN pip install sqlalchemy-redshift

RUN pip install sqlalchemy-trino && \
    pip install trino && \
    # https://github.com/apache/superset/issues/20772
    pip install "apache-superset[databricks]"

COPY --chown=superset pythonpath_dev/superset_config_docker.py /app/pythonpath/
COPY --chown=superset pythonpath_dev/superset_config.py /app/pythonpath/
RUN chmod a+x /app/pythonpath/*.py

# https://github.com/apache/superset/blob/master/Dockerfile
# https://github.com/apache/superset/blob/master/docker/docker-init.sh
COPY --chown=superset docker-bootstrap.sh /app/docker/
COPY --chown=superset docker-init.sh /app/docker/
COPY --chown=superset docker-init-custom.sh /app/docker/
# COPY --chown=superset ./docker/docker-ci.sh /app/docker/

RUN chmod a+x /app/docker/*.sh

# Switching back to using the `superset` user
USER superset

CMD /app/docker/docker-init-custom.sh