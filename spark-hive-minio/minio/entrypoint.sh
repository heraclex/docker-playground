#!/usr/bin/env bash

set -x
set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# start minio
echo "Start Minio...."
# MINIO_ROOT_USER & MINIO_ROOT_PASSWORD will be passed from docker-compose
# MINIO_ROOT_USER=minio 
# MINIO_ROOT_PASSWORD=minio123 
minio server /data --console-address ":9001" & 
while [ $(ps -aef | grep minio | grep 9001 | wc -l) != 1 ]; do  printf '.'; sleep 1; done
# https://docs.min.io/docs/minio-client-complete-guide.html
mc alias set myminio http://minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD --api S3v4

# https://docs.min.io/docs/minio-multi-user-quickstart-guide.html
# Create new canned policy by name readwrite-policy using readwrite-policy.json policy file.
# mc admin policy add myminio readwrite-policy $MINIO_HOME/readwrite-policy.json

buckets=("hive" "spark" "delta" "airflow")
suffix=123
for bucket in ${buckets[@]}; do
    if [[ ! $(mc ls myminio | grep "$bucket") ]] && [[ ! $(mc admin user list myminio | grep "$bucket") ]]
    then
        echo "creating bucket $bucket...."
        mc mb myminio/$bucket
        echo "creating user $bucket $bucket$suffix"
        mc admin user add myminio $bucket $bucket$suffix
        mc admin policy attach myminio readwrite --user $bucket
    fi
done


tail -f /dev/null
