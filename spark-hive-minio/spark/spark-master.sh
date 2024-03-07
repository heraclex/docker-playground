#!/bin/bash

echo "$(hostname -i) spark-master" >> /etc/hosts

spark-class org.apache.spark.deploy.master.Master --ip 0.0.0.0 --port 7077 --webui-port 8080

# echo "History server is sarting ...."
# spark-class org.apache.spark.deploy.history.HistoryServer
