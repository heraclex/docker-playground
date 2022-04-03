#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# start minio
echo "Start Minio...."
# MINIO_ROOT_USER=minio 
# MINIO_ROOT_PASSWORD=minio123 
minio server /data --console-address ":9001" & 
while [ $(ps -aef | grep minio | grep 9001 | wc -l) != 1 ]; do  printf '.'; sleep 1; done
# https://docs.min.io/docs/minio-client-complete-guide.html
mc alias set myminio http://minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD --api S3v4
mc mb myminio/hive 
mc mb myminio/spark 
# create dummy file to test
# touch "${MINIO_HOME}/dummy" 
# mc cp "${MINIO_HOME}/dummy" myminio/hive/default/dummy

tail -f /dev/null
