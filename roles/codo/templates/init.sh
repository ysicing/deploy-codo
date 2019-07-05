#!/bin/bash

set -e

cd {{ ln_workdir }}

docker-compose pull

docker-compose up -d

sleep 30

# admin
docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_admin default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i admin python3 /var/www/codo-admin/db_sync.py

# cmdb

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_cmdb default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i cmdb python3 /var/www/codo-cmdb/db_sync.py

# config

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_kerrigan default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i config python3 /var/www/kerrigan/db_sync.py

# cron

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_cron default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i cron python3 /var/www/codo-cron/db_sync.py

# dns

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_dns default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i domain python3 /var/www/codo-dns/db_sync.py

# task

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_task default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i task python3 /var/www/codo-task/db_sync.py

# tools

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools create database if not exists codo_tools default character set utf8mb4 collate utf8mb4_unicode_ci;

docker run -i --rm -e DB_PASS={{ MYSQL_ROOT_PASSWORD }} --net=host opencodo/sqltools show databases;

docker exec -i tools python3 /var/www/codo-tools/db_sync.py

# init db

#docker exec -i mysql sh -c 'exec mysql -uroot -p{{ MYSQL_ROOT_PASSWORD }} -D codo_admin' < {{ ln_workdir }}/sql/init.sql
#docker exec -i mysql sh -c 'exec mysql -uroot -p{{ MYSQL_ROOT_PASSWORD }} -D codo_admin' < {{ ln_workdir }}/sql/user.sql