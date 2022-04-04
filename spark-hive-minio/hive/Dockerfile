# FROM openjdk:8-jre
FROM local/centos7-java8:latest

LABEL Description="Hive metastore standalone"

WORKDIR /

# Hadoop
ARG HADOOP_VERSION=3.2.0
ENV HADOOP_HOME /usr/hadoop
ENV PATH="${PATH}:${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin"
RUN curl --progress-bar -L --retry 3 \
    "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ && \
    mv "/usr/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}" && \
    rm -rf "${HADOOP_HOME}/share/doc" && \
    chown -R root:root "${HADOOP_HOME}"


# Hive
ARG METASTORE_VERSION=3.0.0
ENV HIVE_HOME /usr/hive-standalone-metastore
ENV PATH "${PATH}:${HIVE_HOME}/bin"
RUN curl --progress-bar -L --retry 3 \
"https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ && \
    mv "/usr/apache-hive-metastore-${METASTORE_VERSION}-bin" "${HIVE_HOME}" && \
    chown -R root:root "${HIVE_HOME}"

# JDBC connectors: postgres | mysql
ARG POSTGRESSQL_VERSION=42.2.16
ARG MYSQLSSQL_VERSION=8.0.19
RUN curl --progress-bar -L https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar \
    --output ${HIVE_HOME}/lib/postgresql-jdbc.jar && \
    curl --progress-bar -L https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQLSSQL_VERSION}/mysql-connector-java-${MYSQLSSQL_VERSION}.jar \
    --output ${HIVE_HOME}/lib/mysql-jdbc.jar
    

# download delta-hive-assembly
RUN curl -o delta-hive-assembly_2.11-0.2.0.jar https://github.com/delta-io/connectors/releases/download/v0.2.0/delta-hive-assembly_2.11-0.2.0.jar && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HIVE_HOME}/lib/ && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
    rm -f delta-hive-assembly_2.11-0.2.0.jar

# download aws-java-sdk
RUN curl -o aws-java-sdk-1.11.534.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar && \
    cp aws-java-sdk-1.11.534.jar ${HIVE_HOME}/lib/ && \
    cp aws-java-sdk-1.11.534.jar ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/ && \
    rm -f aws-java-sdk-1.11.534.jar

ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/delta-hive-assembly_2.11-0.2.0.jar

EXPOSE 9083

# Entry point: start all services and applications.
COPY metastore-site.xml ${HIVE_HOME}/conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
