

FROM centos:7

LABEL Description="Java + CentOS (OpenJDK)"

ARG JAVA_VERSION=8
ARG JAVA_RELEASE=JDK

ENV JAVA_HOME=/usr

# update all packages include curl
RUN yum -y update && \
    yum install -y telnet wget hostname ca-certificates \
    openssh-server openssh-clients tar which net-tools 

### Install JAVA8 ###
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


### Install python 3.7 ###
ARG PYTHON_VERSION=3.7.5
# 1.Requirements:

RUN yum -y install gcc openssl-devel bzip2-devel make

# 2.Download Python 3.7:

RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
    && tar xzf Python-$PYTHON_VERSION.tgz \
# 3.Install Python 3.7.5:   
    && cd /usr/src/Python-$PYTHON_VERSION \
    && ./configure --enable-optimizations \
    && make altinstall

# (make altinstall is used to prevent replacing the default python binary file /usr/bin/python)

# 4.Remove downloaded source archive file from your system:

RUN rm /usr/src/Python-$PYTHON_VERSION.tgz

# 5.Check Python Version

RUN python3.7 -V

RUN echo 'alias python3.7="python3"' >> ~/.bashrc

COPY profile.d/java.sh /etc/profile.d/


