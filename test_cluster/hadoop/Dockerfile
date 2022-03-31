FROM local/centos7-java8:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Hadoop Dev", \
      "Hadoop Version"="$HADOOP_VERSION"

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



# Spark
ARG SPARK_VERSION=3.2.1
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-without-hadoop"
ENV SPARK_HOME /usr/spark
ENV PATH="${PATH}:${SPARK_HOME}/sbin:${SPARK_HOME}/bin"
RUN curl --progress-bar -L --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv "/usr/${SPARK_PACKAGE}" "${SPARK_HOME}" \
 && chown -R root:root "${SPARK_HOME}"
# For inscrutable reasons, Spark distribution doesn't include spark-hive.jar
# Livy attempts to load it though, and will throw
# java.lang.ClassNotFoundException: org.apache.spark.sql.hive.HiveContext
ARG SCALA_VERSION=2.11
RUN curl --progress-bar -L \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
    --output "${SPARK_HOME}/jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar"

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
COPY conf/hadoop/core-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hadoop-env.sh "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hdfs-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/mapred-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/workers "${HADOOP_CONF_DIR}"
COPY conf/hadoop/yarn-site.xml "${HADOOP_CONF_DIR}"

# Hive setup
ENV HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:${HIVE_HOME}/lib/*"
COPY conf/hive/hive-site.xml "${HIVE_CONF_DIR}"

# Spark setup
ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV SPARK_LOG_DIR="${SPARK_HOME}/logs"
ENV SPARK_DIST_CLASSPATH="${HADOOP_CONF_DIR}:${HADOOP_HOME}/share/hadoop/tools/lib/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/yarn:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*"
COPY conf/hadoop/core-site.xml "${SPARK_CONF_DIR}"/
COPY conf/hadoop/hdfs-site.xml "${SPARK_CONF_DIR}"/
COPY conf/hive/hive-site.xml "${HIVE_CONF_DIR}"
COPY conf/spark/spark-defaults.conf "${SPARK_CONF_DIR}"/

# Spark with Hive
# TODO enable in Spark 3.0
ENV SPARK_DIST_CLASSPATH="${SPARK_DIST_CLASSPATH}:${HIVE_HOME}/lib/*"
COPY conf/hive/hive-site.xml "${SPARK_CONF_DIR}/"
RUN ln -s "${SPARK_HOME}/jars/scala-library-*.jar" "${HIVE_HOME}/lib" \
   && ln -s "${SPARK_HOME}/jars/spark-core_*.jar" "${HIVE_HOME}/lib" \
   && ln -s "${SPARK_HOME}/jars/spark-network-common_*.jar" "${HIVE_HOME}/lib"

# Clean up
RUN rm -rf "${HIVE_HOME}/examples" \
    && rm -rf "${SPARK_HOME}/examples/src"

# If both YARN Web UI and Spark UI is up, then returns 0, 1 otherwise.
HEALTHCHECK CMD curl -f http://host.docker.internal:8080/ \
    && curl -f http://host.docker.internal:8088/ || exit 1


COPY ssh/config /root/.ssh/
EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090 10000 10002 4040 7077 8080 8081


# Entry point: start all services and applications.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]