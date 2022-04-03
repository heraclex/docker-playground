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
ENV HIVE_HOME /usr/hive-metastore
ENV PATH "${PATH}:${HIVE_HOME}/bin"
RUN curl --progress-bar -L --retry 3 \
    "https://archive.apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ && \
    mv "/usr/apache-hive-metastore-${METASTORE_VERSION}-bin" "${HIVE_HOME}" && \
    chown -R root:root "${HIVE_HOME}"

ARG POSTGRESSQL_VERSION=42.3.3
RUN curl --progress-bar -L https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar \
    --output ${HIVE_HOME}/lib/postgresql-jdbc.jar

# download delta-hive-assembly
RUN curl -o delta-hive-assembly_2.11-0.2.0.jar https://github.com/delta-io/connectors/releases/download/v0.2.0/delta-hive-assembly_2.11-0.2.0.jar && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HIVE_HOME}/lib/ && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HADOOP_HOME}/share/hadoop/tools/lib/

# download aws-java-sdk
RUN curl -o aws-java-sdk-1.11.534.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar && \
    cp aws-java-sdk-1.11.534.jar ${HIVE_HOME}/lib/ && \
    cp aws-java-sdk-1.11.534.jar ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/

ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/delta-hive-assembly_2.11-0.2.0.jar

EXPOSE 9083

# Entry point: start all services and applications.
COPY metastore-site.xml ${HIVE_HOME}/conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# ENV HADOOP_VERSION=3.2.1
# ENV METASTORE_VERSION=3.0.0

# ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
# ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

# RUN curl -L https://archive.apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
#     curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf -

# RUN curl -o mysql-connector-java-8.0.19.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar && \
#     cp mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
#     curl -o delta-hive-assembly_2.11-0.2.0.jar https://github.com/delta-io/connectors/releases/download/v0.2.0/delta-hive-assembly_2.11-0.2.0.jar && \
#     cp delta-hive-assembly_2.11-0.2.0.jar ${HIVE_HOME}/lib/ && \
#     cp delta-hive-assembly_2.11-0.2.0.jar ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
#     curl -o aws-java-sdk-1.11.534.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar && \
#     cp aws-java-sdk-1.11.534.jar ${HIVE_HOME}/lib/ && \
#     cp aws-java-sdk-1.11.534.jar ${HADOOP_HOME}/share/hadoop/tools/lib/ && \
#     cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar ${HIVE_HOME}/lib/

# COPY metastore-site.xml ${HIVE_HOME}/conf
# COPY entrypoint.sh /entrypoint.sh
# # COPY core-site.xml ${HADOOP_HOME}/etc/hadoop/

# RUN groupadd -r hive --gid=1000 && \
#     useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
#     chown hive:hive -R ${HIVE_HOME} && \
#     chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

# ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar:${HADOOP_HOME}/share/hadoop/tools/lib/delta-hive-assembly_2.11-0.2.0.jar
# ENV JAVA_HOME=/usr/local/openjdk-8


# USER hive
# EXPOSE 9083

# ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]