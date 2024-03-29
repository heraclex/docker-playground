FROM local/centos8:latest

ARG kafka_version=2.8.1
ARG scala_version=2.13
ARG glibc_version=2.31-r0
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/heraclex/kafka-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="heraclex"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/usr/kafka
    # GLIBC_VERSION=$glibc_version

ENV PATH=${PATH}:${KAFKA_HOME}/bin

WORKDIR /

ARG FILENAME="kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
RUN curl --progress-bar -L --retry 3 \
    "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${FILENAME}" \
    | gunzip \
    | tar -x -C /usr/ && \
    mv "/usr/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" ${KAFKA_HOME} && \
    rm -f kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    chown -R root:root "${KAFKA_HOME}"

COPY scripts/start-kafka.sh scripts/broker-list.sh scripts/create-topics.sh scripts/versions.sh /tmp/
RUN yum install -y bash curl jq docker && \
    chmod a+x /tmp/*.sh && \
    mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin

# RUN yum install -y bash curl jq docker \
#  && chmod a+x /tmp/*.sh \
#  && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin \
#  && sync && /tmp/download-kafka.sh \
#  && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
#  && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
#  && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
#  && rm /tmp/* 
#  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
#  && yum install -y glibc-${GLIBC_VERSION}.apk \
#  && rm glibc-${GLIBC_VERSION}.apk

# COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]