FROM centos:8

LABEL Description="Centos8 with zulu(8+11)"

# Fix Failed to download metadata for repo
# https://techglimpse.com/failed-metadata-repo-appstream-centos-8/
RUN set -euxo pipefail && \
    cd /etc/yum.repos.d/ && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum -y update


# update all packages include curl
RUN set -euxo pipefail && \
    yum install -y telnet wget hostname ca-certificates \
    openssh-server openssh-clients tar which net-tools 

# add the Azul RPM repository and install zulu8, zulu11 sdk
RUN set -euxo pipefail && \
    yum install -y https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm && \
    yum install -y zulu8-jdk zulu11-jdk

# install python3
RUN set -euxo pipefail && \
    yum install -y python3

# set to java 8 by default. Can be overwrited on dockerfile
# update this java version to the desired java version
ENV JAVA_HOME=/usr/lib/jvm/zulu8
ENV PATH="${PATH}:${JAVA_HOME}"
