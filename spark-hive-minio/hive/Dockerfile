
FROM local/centos8:latest

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

# JDBC connectors: postgres 42.2.16 | mysql
ARG POSTGRESSQL_VERSION=42.2.16
ARG MYSQLSSQL_VERSION=8.0.19
RUN curl --progress-bar -L https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar \
    --output ${HIVE_HOME}/lib/postgresql-jdbc.jar && \
    curl --progress-bar -L https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQLSSQL_VERSION}/mysql-connector-java-${MYSQLSSQL_VERSION}.jar \
    --output ${HIVE_HOME}/lib/mysql-jdbc.jar
    

# download delta-hive-assembly
ARG SCALA_VERSION=2.11
ARG DELTA_HIVE_VERSION=0.2.0
ARG DELTA_HIVE_ASSEMBLY="delta-hive-assembly_$SCALA_VERSION-${DELTA_HIVE_VERSION}.jar"
RUN curl -o $DELTA_HIVE_ASSEMBLY "https://github.com/delta-io/connectors/releases/download/v$DELTA_HIVE_VERSION/$DELTA_HIVE_ASSEMBLY" && \
    cp $DELTA_HIVE_ASSEMBLY ${HIVE_HOME}/lib/ && \
    cp $DELTA_HIVE_ASSEMBLY ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
    rm -f $DELTA_HIVE_ASSEMBLY

# download aws-java-sdk
ARG AWS_JAVA_SDK_VERSION=1.11.534
ARG AWS_JAVA_SDK="aws-java-sdk-${AWS_JAVA_SDK_VERSION}.jar"
RUN curl -o $AWS_JAVA_SDK "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/$AWS_JAVA_SDK_VERSION/$AWS_JAVA_SDK" && \
    cp $AWS_JAVA_SDK ${HIVE_HOME}/lib/ && \
    cp $AWS_JAVA_SDK ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar ${HIVE_HOME}/lib/ && \
    rm -f $AWS_JAVA_SDK



# ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/delta-hive-assembly_2.11-0.2.0.jar
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/

EXPOSE 9083

# Entry point: start all services and applications.
COPY metastore-site.xml ${HIVE_HOME}/conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
