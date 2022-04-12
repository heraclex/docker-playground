

FROM centos:7

LABEL Description="Java + CentOS (OpenJDK)"

ARG JAVA_VERSION=8
ARG JAVA_RELEASE=JDK

ENV JAVA_HOME=/usr

# update all packages include curl
RUN yum -y update && \
    yum install -y telnet wget hostname ca-certificates \
    openssh-server openssh-clients tar which net-tools 

RUN set -euxo pipefail && \
    pkg="java-1.$JAVA_VERSION.0-openjdk" && \
    if [ "$JAVA_RELEASE" = "JDK" ]; then \
        pkg="$pkg-devel"; \
    else \
        pkg="$pkg-headless"; \
    fi; \
    yum install -y "$pkg" && \
    yum clean all && \
    rm -rf /var/cache/yum

# RUN set -euxo pipefail && yum install -y openssh-server openssh-clients tar which

COPY profile.d/java.sh /etc/profile.d/

#CMD /bin/bash
# yum install -y ca-certificates && \
