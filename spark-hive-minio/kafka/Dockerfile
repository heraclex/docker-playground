FROM bitnami/kafka:3.6.0

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

COPY create-topics.sh /tmp2/
RUN unset KAFKA_CREATE_TOPICS