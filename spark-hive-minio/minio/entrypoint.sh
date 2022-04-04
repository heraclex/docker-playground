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

# TODO: need to check if the bucket is exist before creating
mc mb myminio/hive
mc mb myminio/spark

# https://docs.min.io/docs/minio-multi-user-quickstart-guide.html
# Create new canned policy by name readwrite-policy using readwrite-policy.json policy file.
# mc admin policy add myminio readwrite-policy $MINIO_HOME/readwrite-policy.json
mc admin user add myminio hive hive12345
mc admin user add myminio spark spark12345

mc admin policy set myminio readwrite user=hive
mc admin policy set myminio readwrite user=spark

tail -f /dev/null
