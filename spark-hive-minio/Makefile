.PHONY: hive trino superset

minio-build-image:
	docker build minio/. --no-cache -t local/minio:linux-arm64

minio-up:
	docker-compose up -d minio

minio-down:
	docker-compose down -v minio

hive-build-image:
	docker build hive/. --no-cache -t local/hive:3.0.0

hive-up:
	docker-compose up -d hive

hive-down:
	docker-compose down -v hive

trino-cluster:
	docker-compose up -d trino-coordinator
	sleep 2
	docker-compose up -d trino-worker

superset:
	docker-compose up -d superset

spark-build-image:
	docker build spark/. --no-cache -t local/spark:3.5.1

spark-up:
	docker compose -f docker-compose.yml -f spark/compose.spark.yml --profile spark up -d

spark-down:
	docker compose -f docker-compose.yml -f spark/compose.spark.yml --profile spark down -v

airflow-build-image:
	docker build airflow/. --no-cache -t local/airflow:2.7.3

airflow-up:
	docker-compose -f docker-compose.yml -f airflow/compose.airflow.yml --profile airflow up -d

airflow-down:
	docker-compose -f docker-compose.yml -f airflow/compose.airflow.yml --profile airflow down -v

spark-airflow-up:
	docker compose -f docker-compose.yml -f airflow/compose.airflow.yml -f spark/compose.spark.yml --profile airflow --profile spark airflow up -d

down-all: | airflow-down spark-down hive-down
	docker-compose down -v
	sleep 3
	rm -rf */.storage