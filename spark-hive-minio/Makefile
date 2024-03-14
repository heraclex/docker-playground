.PHONY: hive trino superset down

hive:
	docker-compose up -d metastore minio
	sleep 3
	docker-compose up -d hive

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

down-v:
	docker-compose down -v
	sleep 3
	rm -rf .storage
