FROM metabase/metabase:v0.45.2

ENV MB_DB_CONNECTION_TIMEOUT_MS=60000


ARG SPARKSQL_DATABRICKS_DRIVER_VERSION=1.6.0
RUN curl --progress-bar -L https://github.com/relferreira/metabase-sparksql-databricks-driver/releases/download/${SPARKSQL_DATABRICKS_DRIVER_VERSION}/sparksql-databricks.metabase-driver.jar \
    --output /plugins/sparksql-databricks.metabase-driver.jar

# COPY plugins/sparksql-databricks.metabase-driver.jar /plugins/