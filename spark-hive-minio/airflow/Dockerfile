FROM python:3.7-slim-stretch

# Install OpenJDK 8
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
RUN echo $JAVA_HOME

RUN apt-get update -y && apt-get install -y libzbar-dev bash gcc git libc-dev curl wget vim nano \
    && apt-get install -y iputils-ping telnet openssh-client net-tools \
    man unzip vim-tiny bc openssh-server thrift-compiler netcat sudo \
    && apt-get install -y build-essential \
    && apt-get autoremove -y \
    && apt-get clean

ARG SPARK_VERSION=3.2.1
ARG HADOOP_VERSION=3.2
ARG SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
# install spark
RUN curl -o ${SPARK_PACKAGE}.tgz 'https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/$SPARK_PACKAGE.tgz' && \
    tar -xzvf ${SPARK_PACKAGE}.tgz && \
    mv $SPARK_PACKAGE /opt/spark && \
    rm -rf ${SPARK_PACKAGE}.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="${PATH}:${SPARK_HOME}/sbin:${SPARK_HOME}/bin"
ENV PYTHONPATH=$SPARK_HOME/python3:$SPARK_HOME/python3/lib/py4j-0.10.7-src.zip:$PYTHONPATH

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


COPY ./dags ./opt/airflow/dags
RUN chmod -R a+rwx /opt/airflow
COPY airflow.cfg /opt/airflow/airflow.cfg
COPY run.sh ./run.sh
RUN chmod +x /run.sh
WORKDIR /opt/airflow

CMD /run.sh
EXPOSE 8000