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

down-v:
	docker-compose down -v
	sleep 3
	rm -rf .storage
