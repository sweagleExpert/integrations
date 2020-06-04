# SWEAGLE MYSQL CONTAINER

## CONTENT

This is instructions to build SWEAGLE MYSQL container, that could be used to host SWEAGLE data model DB and Vault DB also.

This container is based on MySQL official image that is available here https://hub.docker.com/_/mysql
It includes a specific `init.sh` script to create vault db at first startup of MySQL.

## BUILD IT, TAG IT, PUSH IT

- Change DBs passwords (recommended) and also, user and db names if you want
- build container with command `docker build -t sweagle-mysql:<VERSION> .`
- tag it with `sudo docker tag sweagle-mysql:<VERSION> <YOUR_REGISTRY>/sweagle-mysql:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-mysql:<VERSION>`

where <VERSION> is the version of your MySQL package (default is lastest 5.7 version)


example:

`docker build -t sweagle-mysql:5.7.30 .`

`sudo docker tag sweagle-mysql:5.7.30 docker.sweagle.com:8444/sweagle-mysql:5.7.30`

`sudo docker push docker.sweagle.com:8444/sweagle-mysql:5.7.30`

## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-mysql sweagle-mysql:5.7.30`

- INSIDE
`docker exec -it sweagle-mysql /bin/bash`
then you can run inside your container:
`mysql --version`
`mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE`

- STOP IT
`docker stop sweagle-mysql`

- THEN REMOVE IT
`docker rm sweagle-mysql -f`

## CONFIGURE IT

You can specify your DBs settings through environment variables

example:

`sudo docker run -n sweagle-mysql -e MYSQL_DATABASE="mdm" -e MYSQL_USER="mdm_user" -e MYSQL_PASSWORD="XXXXXX" -it sweagle-mysql:5.7.30`

Environment variables available are:

- MYSQL_ROOT_PASSWORD: your root password

- MYSQL_DATABASE: name of SWEAGLE database schema created when starting mysql first time

- MYSQL_USER: name of SWEAGLE user for database schema created when starting mysql first time

- MYSQL_PASSWORD: password of SWEAGLE user for database schema created when starting mysql first time

- VAULT_DB: name of the vault database schema created when starting mysql the first time

- VAULT_DB_USER: name of VAULT user for database schema created when starting mysql first time

- VAULT_DB_PASSWORD: password of VAULT user for database schema created when starting mysql first time


This container share a volume that contains both databases files for persistence.

## USE IT

Docker-compose configuration (listen only on localhost):

`services:
  sweagle-mysql:
    image: docker.sweagle.com:8444/sweagle-mysql:5.7.30
    volumes:
      - mysql:/var/lib/mysql
    networks:
      stack:`
