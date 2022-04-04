# FROM openjdk:8-jre
# FROM centos:centos8
FROM local/centos7-java8:latest

LABEL Description="Trino dev"

# add the Azul RPM repository 
RUN yum install -y https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm

# install Azul Zulu 11 JDK 
RUN yum install -y zulu11-jdk

ENV JAVA_HOME=/usr/lib/jvm/zulu11


WORKDIR /

ARG TRINO_VERSION=370
ARG TRINO_SERVER_PKG="trino-server-${TRINO_VERSION}.tar.gz"
ARG TRINO_CLIENT_PKG="trino-cli-${TRINO_VERSION}-executable.jar"
ARG TRINO_SERVER_URL="https://repo1.maven.org/maven2/io/trino/trino-server/${TRINO_VERSION}/${TRINO_SERVER_PKG}"
ARG TRINO_CLIENT_URL="https://repo1.maven.org/maven2/io/trino/trino-cli/${TRINO_VERSION}/${TRINO_CLIENT_PKG}"

ENV TRINO_HOME /usr/trino
ENV PATH "${PATH}:${TRINO_HOME}/bin"

# download trino server
RUN set -euxo pipefail && \
    wget $TRINO_SERVER_URL -O $TRINO_SERVER_PKG && \
    tar -xzvf $TRINO_SERVER_PKG -C /usr && \
    mv "/usr/trino-server-${TRINO_VERSION}" "${TRINO_HOME}" && \
    rm -f $TRINO_SERVER_PKG && \
    chown -R root:root $TRINO_HOME

# download trino cli
RUN set -euxo pipefail && \
    wget $TRINO_CLIENT_URL -O "${TRINO_HOME}/lib/$TRINO_CLIENT_PKG"

# Copy configuration files on the host into the image
COPY etc "$TRINO_HOME/etc"

# Specify the entrypoint to start
ENTRYPOINT $TRINO_HOME/bin/launcher run
EXPOSE 8888