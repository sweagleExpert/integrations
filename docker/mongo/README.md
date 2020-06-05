# SWEAGLE MONGODB CONTAINER

## CONTENT

This is instructions to build SWEAGLE MONGODB container, that could be used to host SWEAGLE data.

This container is based on MongoDB 3.4 official image that is available here https://hub.docker.com/_/mongo
It includes specific configuration files for SWEAGLE usage.

## BUILD IT, TAG IT, PUSH IT

- Change DB user, password in file `mongo-init.js`
- build container with command `docker build -t sweagle-mongo:<VERSION> .`
- tag it with `sudo docker tag sweagle-mongo:<VERSION> <YOUR_REGISTRY>/sweagle-mongo:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-mongo:<VERSION>`

where <VERSION> is the version of your mongo package
  - default is 3.4 version for SWEAGLE

example:

`docker build -t sweagle-mongo:3.4 .`

`sudo docker tag sweagle-mongo:3.4 docker.sweagle.com:8444/sweagle-mongo:3.4`

`sudo docker push docker.sweagle.com:8444/sweagle-mongo:3.4`

## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-mongo sweagle-mongo:3.4`

- INSIDE
`docker exec -it sweagle-mongo /bin/bash`
then you can run inside your container:
`mongo --version`
`mongo -u <YOUR_MONGO_USER> -p <YOUR_MONGO_PASSWORD> localhost:27017/sweagle` to connect to SWEAGLE database

- STOP IT
`docker stop sweagle-mongo`

- THEN REMOVE IT
`docker rm sweagle-mongo -f`

## CONFIGURE IT

This container share a volume that contains document database for persistence.

## USE IT

Example of docker-compose configuration:

`
services:
  sweagle-mongo:
    image: docker.sweagle.com:8444/sweagle-mongo:3.4
    volumes:
      - mongo:/data/db
    networks:
      stack:
volumes:
  mongo:
`
