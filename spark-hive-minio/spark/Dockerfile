FROM local/centos7:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Spark Dev"
RUN echo $JAVA_HOME

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Spark
ARG SPARK_VERSION=3.2.1
ARG HADOOP_VERSION=3.2
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
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
ARG SCALA_VERSION=2.12
RUN curl --progress-bar -L \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
    --output "${SPARK_HOME}/jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" && \
    curl --progress-bar -L \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-hive-thriftserver_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
    --output "${SPARK_HOME}/jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar"

# TODO: need to refactor it later
RUN cd "${SPARK_HOME}/jars" && \
    wget --no-verbose https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar && \
    wget --no-verbose https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.874/aws-java-sdk-bundle-1.11.874.jar && \
    wget --no-verbose https://repo1.maven.org/maven2/io/delta/delta-core_2.12/1.0.0/delta-core_2.12-1.0.0.jar && \
    wget --no-verbose https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar && \
    cd /

RUN mkdir -p /opt/spark/history

# Spark setup
ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV SPARK_LOG_DIR="${SPARK_HOME}/logs"
COPY spark-defaults.conf "${SPARK_CONF_DIR}"/

# If both YARN Web UI and Spark UI is up, then returns 0, 1 otherwise.
HEALTHCHECK CMD curl -f http://host.docker.internal:8080/ \
    && curl -f http://host.docker.internal:8088/ || exit 1


# RUN yum clean all && \
#     rm -rf /var/cache/yum && \
#     mkdir /root/.ssh && \
#     chmod 0700 /root/.ssh
# COPY ssh/config /root/.ssh/


EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090 10000 10002 4040 7077 8080 8081


# Entry point: start all services and applications.
# ADD spark-master.sh spark-worker.sh /
COPY spark-master.sh /
COPY spark-worker.sh /
RUN chmod +x /spark-master.sh
RUN chmod +x /spark-master.sh