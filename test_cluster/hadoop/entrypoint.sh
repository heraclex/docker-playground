#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export JAVA_HOME="${JAVA_HOME:-/usr}"

export PATH="$PATH:/hadoop/sbin:/hadoop/bin"
export PATH="$PATH:$HOME/downloads"

export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"

if [ $# -gt 0 ]; then
    exec $@
else
    if ! [ -f /root/.ssh/authorized_keys ]; then
        ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
        cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
        chmod -v 0400 /root/.ssh/authorized_keys
    fi

    if ! [ -f /etc/ssh/ssh_host_rsa_key ]; then
        /usr/sbin/sshd-keygen || :
    fi

    if ! pgrep -x sshd &>/dev/null; then
        /usr/sbin/sshd
    fi
    echo
    SECONDS=0
    while true; do
        if ssh-keyscan localhost 2>&1 | grep -q OpenSSH; then
            echo "SSH is ready to rock"
            break
        fi
        if [ "$SECONDS" -gt 20 ]; then
            echo "FAILED: SSH failed to come up after 20 secs"
            exit 1
        fi
        echo "waiting for SSH to come up"
        sleep 1
    done
    echo
    if ! [ -f /root/.ssh/known_hosts ]; then
        ssh-keyscan localhost || :
        ssh-keyscan 0.0.0.0   || :
    fi | tee -a /root/.ssh/known_hosts
    hostname=$(hostname -f)
    if ! grep -q "$hostname" /root/.ssh/known_hosts; then
        ssh-keyscan $hostname || :
    fi | tee -a /root/.ssh/known_hosts

    mkdir -pv /hadoop/logs

    sed -i "s/localhost/$hostname/" /hadoop/etc/hadoop/core-site.xml

    # start minio
    MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio123 minio server /data --console-address ":9009" & 
    while [ $(ps -aef | grep minio | grep 9009 | wc -l) != 1 ]; do  printf '.'; sleep 1; done
    # ./root/downloads/mc alias set myminio http://127.0.0.1:9009 minio minio123
    # ./root/downloads/mc config host add myminio http://127.0.0.1:9009 minio minio123
    # until(./root/downloads/mc config host add myminio http://127.0.0.1:9009 minio minio123) do echo '...waiting...' && sleep 1; done;
    # ./root/downloads/mc mb myminio/de-sb-logs 
    #  ./root/downloads/mc mb myminio/de-sb-data-lake
    #  ./root/downloads/mc mb myminio/de-dev-sb-data-lake
    #  ./root/downloads/mc mb myminio/de-staging-sb-data-lake
    #  touch ./root/downloads/dummy 
    #  ./root/downloads/mc cp ./root/downloads/dummy myminio/de-sb-data-lake/hive/default/dummy

    # start hadoop

    hdfs namenode -format
    chmod -R 777 /usr/local/Cellar/hadoop/hdfs/tmp
    start-dfs.sh
    start-yarn.sh

    # start hive
    hadoop fs -mkdir       /tmp
    hadoop fs -mkdir -p    /user/hive/warehouse
    hadoop fs -chmod g+w   /tmp
    hadoop fs -chmod g+w   /user/hive/warehouse
  
    cd /hive/bin
    ./hive --service metastore &
    ./hiveserver2 --hiveconf hive.server2.enable.doAs=false &
    cd /

    # start spark-standalone
    export SPARK_DIST_CLASSPATH=$(hadoop classpath)  
    export SPARK_DIST_CLASSPATH=$SPARK_DIST_CLASSPATH:/hive/lib/* 
    "$SPARK_HOME/sbin/start-all.sh"
    # TODO : fail to start worker, fix it
    /usr/spark-3.2.1/sbin/spark-daemon.sh start org.apache.spark.deploy.worker.Worker 1 --webui-port 8081 spark://50093de8bfe8:7077

    tail -f /dev/null /hadoop/logs/*

    stop-yarn.sh
    stop-dfs.sh
fi
