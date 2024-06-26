# FROM local/centos7:latest
# FROM local/centos8:latest
# FROM python:3.9-slim-bullseye
# using alpine to have a very lighweight based image
FROM alpine:3.18
# alpine:3.18 come with python 3.11 and java 17

MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

LABEL Description="Spark Dev"

# RUN echo $JAVA_HOME

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/sh", "-o", "pipefail", "-c"]


# Install dependencies (open-jdk-17 & python3)
RUN apk update
RUN apk add --no-cache openjdk17-jdk python3 python3-dev py3-pip curl wget bash procps
RUN rm -rf /var/cache/apk/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV SPARK_HOME /opt/spark
ENV HADOOP_HOME /opt/hadoop

RUN echo $JAVA_HOME

# Install Spark
ARG SPARK_VERSION=3.5.1
ARG HADOOP_VERSION=3
# ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala2.13"
ARG SCALA_VERSION=2.13
ENV PATH="${PATH}:${SPARK_HOME}/sbin:${SPARK_HOME}/bin"
ENV PYTHONPATH=$SPARK_HOME/python3:$SPARK_HOME/python3/lib/py4j-0.10.7-src.zip:$PYTHONPATH

# https://blog.devgenius.io/spark-streaming-write-to-minio-331f6c91d506
# run this on local only 
COPY jars/${SPARK_PACKAGE}.tgz /opt/
RUN cd /opt/ \
    && tar -xzf ${SPARK_PACKAGE}.tgz \
    && mv /opt/${SPARK_PACKAGE} ${SPARK_HOME} \
    && rm ${SPARK_PACKAGE}.tgz
COPY jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar \
        jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar \
        jars/aws-java-sdk-1.12.262.jar \
        jars/aws-java-sdk-bundle-1.12.262.jar \
        jars/aws-java-sdk-s3-1.12.262.jar \
        jars/aws-java-sdk-core-1.12.262.jar \
        jars/hadoop-aws-3.3.4.jar \
        jars/hadoop-common-3.3.4.jar \
        # jars/hadoop-client-3.3.4.jar \
        # jars/hadoop-mapreduce-client-core-3.3.4.jar \
        jars/delta-core_2.13-2.4.0.jar \
        jars/delta-hive_2.13-3.1.0.jar \
        jars/delta-spark_2.13-3.1.0.jar \
        jars/delta-storage-3.1.0.jar \
     ${SPARK_HOME}/jars/

# Spark setup
ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV SPARK_LOG_DIR="${SPARK_HOME}/logs"

# Set up user and group for Spark
ARG spark_uid=185
RUN addgroup -S -g ${spark_uid} spark && \
    adduser -S -u ${spark_uid} -G spark spark && \
    chown -R spark:spark "${SPARK_HOME}"

# If both YARN Web UI and Spark UI is up, then returns 0, 1 otherwise.
HEALTHCHECK CMD curl -f http://host.docker.internal:8080/ \
    && curl -f http://host.docker.internal:8088/ || exit 1


COPY spark-defaults.conf "${SPARK_CONF_DIR}"/

RUN chmod 755 /opt/spark/sbin/* && \
    chmod 755 /opt/spark/bin/*

# create history and event logs folder
RUN mkdir -p ${SPARK_HOME}/history
RUN chmod 755 ${SPARK_HOME}/history

EXPOSE 4040 7077 8080 18080

# Copy scripts and set permissions
RUN cd /
COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh