#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


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

    # start minio
    echo "Start Minio...."
    # MINIO_ROOT_USER=minio 
    # MINIO_ROOT_PASSWORD=minio123 
    minio server /data --console-address ":9009" & 
    while [ $(ps -aef | grep minio | grep 9009 | wc -l) != 1 ]; do  printf '.'; sleep 1; done
    # https://docs.min.io/docs/minio-client-complete-guide.html
    mc alias set myminio http://minio:9000 minio minio123 --api S3v4
    mc mb myminio/de-logs 
    mc mb myminio/de-data-lake
    # create dummy file to test
    touch "${MINIO_HOME}/dummy" 
    mc cp "${MINIO_HOME}/dummy" myminio/de-data-lake/hive/default/dummy

    tail -f /dev/null
fi
