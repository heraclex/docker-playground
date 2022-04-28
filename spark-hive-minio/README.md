# LakeHouse Solution with Spark - HiveMetastore - Trino
This is a side-project in my free time which is about setting up an dev environment locally based on docker images <br>
There are 2 base docker images used: centos7 & centos8, and other docker images including spark, hive-standalone-metastore, minio and trino will depend on these 2 based imgs.

## Image Descriptions
- `centos7` this is a base image with java8 setup.
- `centos8` this is a base image with java8 and java11 setup. In order to manage multiple jdk versions, I use [Azul Zulu](https://www.azul.com/)
- `minio` for object storage as similar to other cloud based object storage solution on aws, az, gcp.
- `hive` this is only hive-standalone-metastore, not a full version of hive.
- `metastore` postgres:13 image for hive metastoredb.
- `spark` this image for spark engine, there will be 2 nodes in docker-compose: master & worker.
- `trino` this is a query engine after the original name `presto` has been changed.
- `superset` for data visulization.

## How it works
`minio` will be acting as oject storage layer and spark job will output all data to this layer and then update to hive metadata about the location of the table.
```scala
// writing data to s3 minio
df.write.partitionBy("day").mode("overwrite").save(s"s3a://hive/$database.db/$tableName")

// create hive table
spark.sql(
  s"""CREATE EXTERNAL TABLE IF NOT EXISTS $database.$tableName($tableCols)
      PARTITIONED BY (day)
      ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
      STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.SymlinkTextInputFormat'
      OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
      LOCATION 's3a://hive/$database.db/$tableName'""".stripMargin)
```

## Prerequisite
- [docker](https://www.docker.com/)
- [spark 3.x](https://spark.apache.org/docs/latest/index.html)
## Build & Run
Build docker images: 
```
docker-compose build --no-cache centos7 centos8
docker-compose build --no-cache metastore hive trino-coordinator spark-master superset
```
Run all containers at once `docker-compose up -d`
Run specific container/service `docker-compose up -d {services}`
Stop & remove specific container/service `docker-compose rm -sv {services}`
Debug Images `docker-compose run {services} bash`

## 🖥 Nice UIs to play with

- minio UI
http://localhost:9001

- trino UI
http://localhost:8888

- superset
http://localhost:8088