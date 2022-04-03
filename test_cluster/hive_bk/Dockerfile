FROM local/centos7-java8:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Hadoop Dev"

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

################################ Package setup ################################

# Hadoop
ARG HADOOP_VERSION=3.2.1
ENV HADOOP_HOME /usr/hadoop
ENV PATH="${PATH}:${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin"
RUN curl --progress-bar -L --retry 3 \
    "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ && \
    mv "/usr/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}" && \
    rm -rf "${HADOOP_HOME}/share/doc" && \
    chown -R root:root "${HADOOP_HOME}" && \
    "${HADOOP_HOME}/bin/hdfs" namenode -format && \
    yum install -y hostname && \
    yum install -y net-tools 

RUN mkdir -pv "${HADOOP_HOME}/tmp" && \
    mkdir -pv "${HADOOP_HOME}/dfs/name" && \
    mkdir -pv "${HADOOP_HOME}/dfs/data"


# Hive
ARG POSTGRESSQL_VERSION=42.3.3
ARG HIVE_VERSION=3.1.2
ENV HIVE_HOME /usr/hive
ENV HIVE_CONF_DIR="${HIVE_HOME}/conf"
ENV PATH "${PATH}:${HIVE_HOME}/bin"
RUN curl --progress-bar -L \
    "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
      | gunzip \
      | tar -x -C /usr/ && \
    mv "/usr/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}" && \
    chown -R root:root "${HIVE_HOME}" && \
    mkdir -p "${HIVE_HOME}/hcatalog/var/log" && \
    mkdir -p "${HIVE_HOME}/var/log" && \
    mkdir -p "${HIVE_CONF_DIR}" && \
    chmod 777 "${HIVE_HOME}/hcatalog/var/log" && \
    chmod 777 "${HIVE_HOME}/var/log"

RUN curl --progress-bar -L \
    "https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar" \
    --output ${HIVE_HOME}/lib/postgresql-jdbc.jar

RUN curl -o delta-hive-assembly_2.11-0.2.0.jar https://github.com/delta-io/connectors/releases/download/v0.2.0/delta-hive-assembly_2.11-0.2.0.jar && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HIVE_HOME}/lib/ && \
    cp delta-hive-assembly_2.11-0.2.0.jar ${HADOOP_HOME}/share/hadoop/tools/lib/



RUN yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir /root/.ssh && \
    chmod 0700 /root/.ssh



################################ ENV setup ################################

# Common settings
# ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

# Hadoop setup
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"
ENV LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}"
ENV HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
ENV HADOOP_LOG_DIR="${HADOOP_HOME}/logs"
# For S3 to work. Without this line you'll get "Class org.apache.hadoop.fs.s3a.S3AFileSystem not found" exception when accessing S3 from Hadoop
ENV HADOOP_CLASSPATH="${HADOOP_HOME}/share/hadoop/tools/lib/*"

COPY conf/hadoop/core-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hadoop-env.sh "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hdfs-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/mapred-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/workers "${HADOOP_CONF_DIR}"
COPY conf/hadoop/yarn-site.xml "${HADOOP_CONF_DIR}"

# Hive setup
ENV HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:${HIVE_HOME}/lib/*"
COPY conf/hive/hive-site.xml ${HIVE_CONF_DIR}
COPY conf/hive/metastore-site.xml ${HIVE_CONF_DIR}

# Clean up
RUN rm -rf "${HIVE_HOME}/examples" \
    && rm -rf "${SPARK_HOME}/examples/src"

# If both YARN Web UI and Spark UI is up, then returns 0, 1 otherwise.
HEALTHCHECK CMD curl -f http://host.docker.internal:8080/ \
    && curl -f http://host.docker.internal:8088/ || exit 1


COPY ssh/config /root/.ssh/
EXPOSE 9083


# Entry point: start all services and applications.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]