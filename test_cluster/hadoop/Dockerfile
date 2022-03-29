FROM test_cluster_centos7-java8:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Hadoop Dev", \
      "Hadoop Version"="$HADOOP_VERSION"

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


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
# RUN wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar -O ${HIVE_HOME}/lib/postgresql-jdbc.jar
RUN curl --progress-bar -L -o ${HIVE_HOME}/lib/postgresql-jdbc.jar \ 
    "https://jdbc.postgresql.org/download/postgresql-${POSTGRESSQL_VERSION}.jar"
    


# Hadoop env setup
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"
ENV LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}"
ENV HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
ENV HADOOP_LOG_DIR="${HADOOP_HOME}/logs"


# Common settings
# ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

# Hadoop copy
COPY conf/hadoop/core-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hadoop-env.sh "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hdfs-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/mapred-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/workers "${HADOOP_CONF_DIR}"
COPY conf/hadoop/yarn-site.xml "${HADOOP_CONF_DIR}"

# Hive copy
COPY conf/hive/hive-site.xml "${HIVE_CONF_DIR}"

COPY conf/minio/minio-config.json /root/.mc/config.json
COPY ssh/config /root/.ssh/

COPY entrypoint.sh /
CMD "/entrypoint.sh"