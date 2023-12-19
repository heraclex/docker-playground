# cd airflow/dags/jars
echo ${PWD}

SPARK_VERSION=3.5.0
HADOOP_VERSION=3
SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
SCALA_VERSION=2.12

# curl  -L  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
#         --output "${SPARK_PACKAGE}.tgz"

# download spark jars
curl  -L  "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
        --output "jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar"
curl  -L  "https://repo1.maven.org/maven2/org/apache/spark/spark-hive-thriftserver_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
        --output "jars/spark-hive-thriftserver_${SCALA_VERSION}-${SPARK_VERSION}.jar"

curl  -L  "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.534/aws-java-sdk-1.11.534.jar" \
        --output "jars/aws-java-sdk-1.11.534.jar"
curl  -L  "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.874/aws-java-sdk-bundle-1.11.874.jar" \
        --output "jars/aws-java-sdk-bundle-1.11.874.jar"
curl  -L  "https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar" \
        --output "jars/delta-core_2.12-2.4.0.jar"
curl  -L  "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar" \
        --output "jars/hadoop-aws-3.2.0.jar"

# cd ../../..