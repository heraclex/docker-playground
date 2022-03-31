FROM local/centos7-java8:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

ARG MINIO_VERSION=linux-arm64

LABEL Description="Minio Dev", \
      "Minio Version"="${MINIO_VERSION}"

WORKDIR /

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Minio
ENV MINIO_HOME /usr/minio
ENV PATH="${PATH}:${MINIO_HOME}"
RUN mkdir ${MINIO_HOME} && \
    curl --progress-bar -L "https://dl.min.io/server/minio/release/${MINIO_VERSION}/minio" --output "${MINIO_HOME}/minio" && \
    curl --progress-bar -L "https://dl.min.io/client/mc/release/${MINIO_VERSION}/mc" --output "${MINIO_HOME}/mc" && \
    chown -R root:root "${MINIO_HOME}" && \
    chmod +x ${MINIO_HOME}/minio && \
    chmod +x ${MINIO_HOME}/mc

# minio setup
COPY conf/minio-config.json /root/.mc/config.json

EXPOSE 9009

COPY ssh/config /root/.ssh/
# Entry point: start all services and applications.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]