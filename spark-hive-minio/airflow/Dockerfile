FROM apache/airflow:2.7.3
# FROM python:3.9-slim

USER root

# Install OpenJDK 17
RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
RUN echo $JAVA_HOME

# Update & install apt-get packages
# RUN apt-get update -y && \
#     apt-get install -y \
#     libzbar-dev \
#     bash \
#     gosu \
#     gcc \
#     git \
#     libc-dev \
#     curl \
#     wget \
#     vim \
#     nano \
#     iputils-ping \
#     telnet \
#     openssh-client \
#     net-tools \
#     man \
#     unzip \
#     vim-tiny \
#     bc \
#     openssh-server \
#     thrift-compiler \
#     # netcat \
#     sudo \
#     build-essential

# RUN apt-get autoremove -y
# RUN apt-get clean


# Install Spark
ARG SPARK_VERSION=3.5.0
ARG HADOOP_VERSION=3
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
ENV SPARK_HOME=/opt/spark

RUN curl --progress-bar -L --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv "/usr/${SPARK_PACKAGE}" "${SPARK_HOME}" 
 # && chown -R root:root "${SPARK_HOME}"


ENV PATH="${PATH}:${SPARK_HOME}/sbin:${SPARK_HOME}/bin"
ENV PYTHONPATH=$SPARK_HOME/python3:$SPARK_HOME/python3/lib/py4j-0.10.7-src.zip:$PYTHONPATH


COPY ./dags ./opt/airflow/dags
COPY airflow.cfg /opt/airflow/airflow.cfg
RUN chmod -R a+rwx /opt/airflow 

COPY run.sh ./run.sh
RUN chmod +x ./run.sh

USER airflow
# Install extra packages
COPY requirements.txt requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


WORKDIR /opt/airflow

CMD ./run.sh
EXPOSE 8000