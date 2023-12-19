# FROM local/centos7:latest
# FROM local/centos8:latest
# FROM python:3.9-slim-bullseye
# using alpine to have a very lighweight based image
FROM alpine:3.18.5

MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Spark Dev"

# RUN echo $JAVA_HOME

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/sh", "-o", "pipefail", "-c"]


# Install dependencies (open-jdk-17 & python3)
RUN apk update
RUN apk add --no-cache openjdk17-jdk python3 python3-dev py3-pip curl wget bash
RUN rm -rf /var/cache/apk/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin
RUN echo $JAVA_HOME

# Install Spark
ARG SPARK_VERSION=3.5.0
ARG HADOOP_VERSION=3
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
ARG SCALA_VERSION=2.12
ENV SPARK_HOME /opt/spark
ENV PATH="${PATH}:${SPARK_HOME}/sbin:${SPARK_HOME}/bin"
ENV PYTHONPATH=$SPARK_HOME/python3:$SPARK_HOME/python3/lib/py4j-0.10.7-src.zip:$PYTHONPATH


# run this on local only 
COPY jars/${SPARK_PACKAGE}.tgz /opt/
RUN cd /opt/ \
    && tar -xzf ${SPARK_PACKAGE}.tgz \
    && mv /opt/${SPARK_PACKAGE} ${SPARK_HOME} \
    && rm ${SPARK_PACKAGE}.tgz
COPY jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar \
        jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar \
        jars/aws-java-sdk-1.11.534.jar \
        jars/aws-java-sdk-bundle-1.11.874.jar \
        jars/delta-core_2.12-2.4.0.jar \
        jars/hadoop-aws-3.2.0.jar \
     ${SPARK_HOME}/jars/


# RUN curl -L "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" | tar xz -C /opt/ \
#  && mv "/opt/${SPARK_PACKAGE}" "${SPARK_HOME}" 
#  #&& rm -rf "${SPARK_HOME}/examples" "${SPARK_HOME}/data" "${SPARK_HOME}/docs" "${SPARK_HOME}/licenses" "${SPARK_HOME}/sbin"

# For inscrutable reasons, Spark distribution doesn't include spark-hive.jar
# Livy attempts to load it though, and will throw
# java.lang.ClassNotFoundException: org.apache.spark.sql.hive.HiveContext

# RUN curl -L "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
#         --output "${SPARK_HOME}/jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" && \
#     curl -L "https://repo1.maven.org/maven2/org/apache/spark/spark-hive-thriftserver_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
#         --output "${SPARK_HOME}/jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar"



### WILL BE REMOVED ###
# RUN curl --progress-bar -L --retry 1 \
#   "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
#   | gunzip \
#   | tar x -C /opt/ \
#  && mv "/opt/${SPARK_PACKAGE}" "${SPARK_HOME}" \
#  && chown -R spark:spark "${SPARK_HOME}"

# For inscrutable reasons, Spark distribution doesn't include spark-hive.jar
# Livy attempts to load it though, and will throw
# java.lang.ClassNotFoundException: org.apache.spark.sql.hive.HiveContext

# RUN curl --progress-bar -L \
#     "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
#     --output "${SPARK_HOME}/jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" && \
#     curl --progress-bar -L \
#     "https://repo1.maven.org/maven2/org/apache/spark/spark-hive-thriftserver_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
#     --output "${SPARK_HOME}/jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar"




# # TODO: need to refactor it later
# RUN cd "${SPARK_HOME}/jars" && \
#     wget --no-verbose https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar && \
#     wget --no-verbose https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.874/aws-java-sdk-bundle-1.11.874.jar && \
#     wget --no-verbose https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar && \
#     wget --no-verbose https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar && \
#     cd /

RUN mkdir -p /opt/spark/history

# Spark setup
ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV SPARK_LOG_DIR="${SPARK_HOME}/logs"
COPY spark-defaults.conf "${SPARK_CONF_DIR}"/

# Set up user and group for Spark
ARG spark_uid=185
RUN addgroup -S -g ${spark_uid} spark && \
    adduser -S -u ${spark_uid} -G spark spark && \
    chown -R spark:spark "${SPARK_HOME}"

# If both YARN Web UI and Spark UI is up, then returns 0, 1 otherwise.
HEALTHCHECK CMD curl -f http://host.docker.internal:8080/ \
    && curl -f http://host.docker.internal:8088/ || exit 1


# Copy scripts and set permissions
RUN cd /
COPY spark-master.sh spark-worker.sh /
RUN chmod +x /spark-master.sh /spark-worker.sh



