#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export JAVA_HOME="${JAVA_HOME:-/usr}"
echo "export JAVA_HOME=$JAVA_HOME"

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


    # start hadoop

    # echo "format namenode..." 
    # yes | hdfs namenode -format
    # chmod -R 777 /usr/local/Cellar/hadoop/hdfs/tmp
    start-dfs.sh
    start-yarn.sh

    # start hive
    # hadoop fs -mkdir       /tmp
    # hadoop fs -mkdir -p    /user/hive/warehouse
    # hadoop fs -chmod g+w   /tmp
    # hadoop fs -chmod g+w   /user/hive/warehouse
    
    echo "Configuring Hive..."
    
    rm "${HIVE_HOME}/lib/guava-19.0.jar"
    cp "${HADOOP_HOME}/share/hadoop/hdfs/lib/guava-27.0-jre.jar" "${HIVE_HOME}/lib/"

    # schematool -dbType postgres -initSchema

    # Start metastore service.
    hive --service metastore &

    # JDBC Server.
    hiveserver2 &
  
    # cd /hive/bin
    # ./hive --service metastore &
    # ./hiveserver2 --hiveconf hive.server2.enable.doAs=false &
    # cd /

    tail -f /dev/null "${HADOOP_LOG_DIR}/*"

    stop-yarn.sh
    stop-dfs.sh
fi
