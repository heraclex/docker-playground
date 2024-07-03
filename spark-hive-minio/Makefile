.PHONY: hive trino superset down

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
	docker-compose up -d spark-master spark-worker-1 spark-worker-2 spark-history

spark-down:
	docker-compose down -v spark-master spark-worker-1 spark-worker-2 spark-history

airflow:
	docker-compose up -d postgres redis airflow-init airflow-webserver airflow-scheduler airflow-worker airflow-triggerer

airflow-1: 
	docker compose -f docker-compose.yml -f airflow/compose.airflow.yml --profile airflow up -d

spark-airflow:
	docker compose -f docker-compose.yml -f airflow/compose.airflow.yml -f spark/compose.spark.yml --profile airflow --profile spark up -d

down-v:
	docker-compose down -v
	sleep 3
	rm -rf .storage
