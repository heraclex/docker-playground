# cd airflow/dags/jars
echo ${PWD}

SPARK_VERSION=3.5.1
HADOOP_VERSION=3
SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
# download spark
# curl  -L  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
#         --output "${SPARK_PACKAGE}.tgz"

SCALA_VERSION=2.13

spark_packages=(
    "spark-hive_$SCALA_VERSION==$SPARK_VERSION"
    "spark-hive-thriftserver_$SCALA_VERSION==$SPARK_VERSION"
)

# How to resolve Hadoop-aws dependencies in spark extra jars:
# => https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-aws/3.3.4
# => https://blog.devgenius.io/spark-streaming-write-to-minio-331f6c91d506
hadoop_packages=(
    'hadoop-aws==3.3.4'
    'hadoop-common==3.3.4'
    'hadoop-client==3.3.4'
    'hadoop-mapreduce-client-core==3.3.4'
)

aws_packages=(
    'aws-java-sdk==1.12.262'
    'aws-java-sdk-bundle==1.12.262'
    'aws-java-sdk-s3==1.12.262'
    'aws-java-sdk-core==1.12.262'
)

scala_version=2.12
delta_packages=(
    "delta-core_$scala_version==2.4.0"
    "delta-hive_$scala_version==3.1.0"
    "delta-spark_$scala_version==3.1.0"
    "delta-storage==3.1.0"
)


# # download spark-packages jars
# for index in "${spark_packages[@]}" ; do
#     package_name="${index%%==*}"
#     package_version="${index##*==}"
#     echo "\n >>> donwload $package_name==$package_version...."
#     curl  -L  "https://repo1.maven.org/maven2/org/apache/spark/${package_name}/$package_version/${package_name}-${package_version}.jar" \
#         --output "jars/${package_name}-${package_version}.jar"
# done

# # download aws packages 
# for index in "${aws_packages[@]}" ; do
#     package_name="${index%%==*}"
#     package_version="${index##*==}"
#     echo "\n >>> donwload $package_name==$package_version...."
#     curl  -L  "https://repo1.maven.org/maven2/com/amazonaws/$package_name/$package_version/${package_name}-${package_version}.jar" \
#         --output "jars/${package_name}-${package_version}.jar"
# done

# # download hadoop packages 
# for index in "${hadoop_packages[@]}" ; do
#     package_name="${index%%==*}"
#     package_version="${index##*==}"
#     echo "\n >>> donwload $package_name==$package_version...."
#     curl  -L  "https://repo1.maven.org/maven2/org/apache/hadoop/$package_name/$package_version/${package_name}-${package_version}.jar" \
#         --output "jars/${package_name}-${package_version}.jar"
# done

# download delta packages 
# for index in "${delta_packages[@]}" ; do
#     package_name="${index%%==*}"
#     package_version="${index##*==}"
#     echo "\n >>> donwload $package_name==$package_version...."
#     curl  -L  "https://repo1.maven.org/maven2/io/delta/$package_name/$package_version/${package_name}-${package_version}.jar" \
#         --output "jars/${package_name}-${package_version}.jar"
# done

# cd ../../..