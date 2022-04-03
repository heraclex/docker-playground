#!/bin/sh

echo "Replacing guava "
rm -f $HIVE_HOME/lib/guava-*.jar && cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-*.jar $HIVE_HOME/lib/

schematool -initSchema -dbType postgres
start-metastore