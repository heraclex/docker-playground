FROM test_cluster_centos7-java8:latest
MAINTAINER Toan Le (https://www.linkedin.com/in/toanlee/)

ARG HADOOP_VERSION=3.2.1

ARG HIVE_VERSION=3.1.2

ARG TAR=hadoop-$HADOOP_VERSION.tar.gz

ENV PATH $PATH:/hadoop/bin:/hive/bin/
ENV SPARK_VERSION=3.2.1
ENV SPARK_HOME=/usr/spark-${SPARK_VERSION}

###### Its a hack for now #######
ENV SPARK_DIST_CLASSPATH=/hadoop-${HADOOP_VERSION}/etc/hadoop:/${HADOOP_VERSION}/share/hadoop/common/lib/*:/hadoop-${HADOOP_VERSION}/share/hadoop/common/*:/hadoop-${HADOOP_VERSION}/share/hadoop/hdfs:/hadoop-${HADOOP_VERSION}/share/hadoop/hdfs/lib/*:/hadoop-${HADOOP_VERSION}/share/hadoop/hdfs/*:/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/lib/*:/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/*:/hadoop-${HADOOP_VERSION}/share/hadoop/mapreduce/lib/*:/hadoop-${HADOOP_VERSION}/share/hadoop/mapreduce/*:/hadoop/contrib/capacity-scheduler/*.jar:/hive/lib/*
###### Its a hack for now #######


LABEL Description="Hadoop Dev", \
      "Hadoop Version"="$HADOOP_VERSION"

WORKDIR /

RUN set -euxo pipefail && \
    yum install -y openssh-server openssh-clients tar which

RUN set -euxo pipefail && \
    yum install -y wget hostname && \
    # --max-redirect - some apache mirrors redirect a couple times and give you the latest version instead
    #                  but this breaks stuff later because the link will not point to the right dir
    #                  (and is also the wrong version for the tag)
    wget -t 10 --max-redirect 1 --retry-connrefused -O "$TAR" "http://www.apache.org/dyn/closer.lua?filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz&action=download" || \
    wget -t 10 --max-redirect 1 --retry-connrefused -O "$TAR" "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz" && \
    tar zxf "$TAR" && \
    # check tarball was extracted to the right place, helps ensure it's the right version and the link will work
    test -d "hadoop-$HADOOP_VERSION" && \
    ln -sv "hadoop-$HADOOP_VERSION" hadoop && \
    rm -fv "$TAR" && \
    { rm -rf hadoop/share/doc; : ; } && \
    /hadoop/bin/hdfs namenode -format && \
    # gets autoremoved, ensure it's added back as Hadoop scripts need it
    rm -f /hadoop/share/hadoop/common/lib/jackson*.jar && \
    yum install -y hostname && \
    yum install -y net-tools 
    
    # minio installation for arm64
    # TODO - should have been a separate docker-file
RUN set -euxo pipefail && \
    mkdir /root/downloads && \
    cd /root/downloads && \
    wget https://dl.min.io/server/minio/release/linux-arm64/minio && \
    wget https://dl.min.io/client/mc/release/linux-arm64/mc && \
    chmod +x minio && \
    chmod +x mc && \
    cd / 
  
# hive installation Hive 3.x
# TODO - move to different dockerfile
RUN set -euxo pipefail && \
    wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzvf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    mv apache-hive-${HIVE_VERSION}-bin hive && \
    wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -O /hive/lib/postgresql-jdbc.jar && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz 
    
# spark installation 3.x
RUN set -euxo pipefail && \
    wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz && \

    tar -xvf spark-$SPARK_VERSION-bin-without-hadoop.tgz && \ 
    mv spark-$SPARK_VERSION-bin-without-hadoop $SPARK_HOME && \
    chown -R root:root $SPARK_HOME 

RUN set -euxo pipefail && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir /root/.ssh && \
    chmod 0700 /root/.ssh
    

COPY entrypoint.sh /
COPY lib/aws-java-sdk-1.12.184.jar /hadoop/share/hadoop/common/lib/
COPY lib/hadoop-aws-3.2.1.jar  /hadoop/share/hadoop/common/lib/

COPY lib/jackson-core-2.12.3.jar /hadoop/share/hadoop/common/lib/
COPY lib/jackson-module-jaxb-annotations-2.12.3.jar /hadoop/share/hadoop/common/lib/
COPY lib/jackson-databind-2.12.3.jar /hadoop/share/hadoop/common/lib/
COPY lib/jackson-annotations-2.12.3.jar /hadoop/share/hadoop/common/lib/
COPY lib/jackson-jaxrs-json-provider-2.12.3.jar /hadoop/share/hadoop/common/lib/

COPY conf/core-site.xml /hadoop/etc/hadoop/
COPY conf/hdfs-site.xml /hadoop/etc/hadoop/
COPY conf/yarn-site.xml /hadoop/etc/hadoop/
COPY conf/minio-config.json /root/.mc/config.json
COPY conf/mapred-site.xml /hadoop/etc/hadoop/
COPY hive/conf/hive-site.xml /hive/conf
COPY profile.d/hadoop.sh /etc/profile.d/
COPY ssh/config /root/.ssh/

EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090 9009 10000 10002 4040 7077 8080 8081

CMD "/entrypoint.sh"
