#!/bin/bash

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

if [ "$SPARK_WORKLOAD" == "master" ];
then
    #start-master.sh -p 7077
    echo "$(hostname -i) spark-master" >> /etc/hosts
    spark-class org.apache.spark.deploy.master.Master --ip 0.0.0.0 --port 7077 --webui-port 8080

elif [ "$SPARK_WORKLOAD" == "worker" ];
then
    #start-worker.sh spark://spark-master:7077
    echo "starting spark worker"
    spark-class org.apache.spark.deploy.worker.Worker spark://spark-master:7077 --webui-port 8081

elif [ "$SPARK_WORKLOAD" == "history" ]
then
    # start-history-server.sh
    spark-class org.apache.spark.deploy.history.HistoryServer
fi