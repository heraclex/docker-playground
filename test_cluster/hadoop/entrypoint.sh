#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# export JAVA_HOME="${JAVA_HOME:-/usr}"
# echo "export JAVA_HOME=$JAVA_HOME"

# Hadoop shell scripts assume USER is defined
# export USER="${USER:-$(whoami)}"

# export PATH="$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin"
# export PATH="$PATH:$HOME/downloads"

# export HDFS_NAMENODE_USER="root"
# export HDFS_DATANODE_USER="root"
# export HDFS_DATANODE_SECURE_USER="root"
# export HDFS_SECONDARYNAMENODE_USER="root"
# export YARN_RESOURCEMANAGER_USER="root"
# export YARN_NODEMANAGER_USER="root"


if [ $# -gt 0 ]; then
    exec $@
else
    if ! [ -f /root/.ssh/authorized_keys ]; then
        echo "run ssh-keygen"
        ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
        cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
        chmod -v 0600 /root/.ssh/authorized_keys
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

    mkdir -pv "${HADOOP_LOG_DIR}"

    sed -i "s/localhost/$hostname/" "${HADOOP_HOME}/etc/hadoop/core-site.xml"

    # # start minio
    # echo "Start Minio"
    # MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio123 minio server /data --console-address ":9009" & 
    # while [ $(ps -aef | grep minio | grep 9009 | wc -l) != 1 ]; do  printf '.'; sleep 1; done
    # # https://docs.min.io/docs/minio-client-complete-guide.html
    # mc alias set myminio http://hadoop:9000 minio minio123 --api S3v4
    # mc mb myminio/de-logs 
    # mc mb myminio/de-data-lake
    # # create dummy file to test
    # touch "${MINIO_HOME}/dummy" 
    # mc cp "${MINIO_HOME}/dummy" myminio/de-data-lake/hive/default/dummy

    # start hadoop
    start-dfs.sh
    start-yarn.sh
    
    # fixing error java.lang.NoSuchMethodError com.google.common.base.Preconditions.checkArgument
    # https://issues.apache.org/jira/browse/HIVE-22915?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&focusedCommentId=17196051#comment-17196051
    echo "Replacing guava "
    rm "${HIVE_HOME}/lib/guava-19.0.jar"
    cp "${HADOOP_HOME}/share/hadoop/hdfs/lib/guava-27.0-jre.jar" "${HIVE_HOME}/lib/"
    
    echo "Start metastore service..."
    hive --service metastore &
    # JDBC Server.
    hiveserver2 &
  
    # cd /hive/bin
    # ./hive --service metastore &
    # ./hiveserver2 --hiveconf hive.server2.enable.doAs=false &
    # cd /

     # start spark-standalone
     echo "Start Spark Engine..."
    "$SPARK_HOME/sbin/start-all.sh"
    # TODO : fail to start worker, fix it
    spark-daemon.sh start org.apache.spark.deploy.worker.Worker 1 --webui-port 8081 spark://hadoop:7077
    echo "Access Spark Master Url: http://127.0.0.1:8080/"
    echo "Access Spark Worker Url: http://127.0.0.1:8081/"

    tail -f /dev/null ${HADOOP_LOG_DIR}/*

    stop-yarn.sh
    stop-dfs.sh
fi
