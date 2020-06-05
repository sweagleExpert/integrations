# SWEAGLE ELASTICSEARCH CONTAINER

## CONTENT

This is instructions to build SWEAGLE ELASTICSEARCH container, that could be used to host SWEAGLE indexed data.

This container is based on Elastic Search 6.8.6 official image that is available here https://www.docker.elastic.co/
It includes specific configuration files for SWEAGLE usage.

## BUILD IT, TAG IT, PUSH IT

- Change XMS, XMX in `jvm.options` or through env variables file based on your requirements
  - `512m` is good value for POC single instance
  - `2G`, at least, is more recommended for production instance
- build container with command `docker build -t sweagle-elasticsearch:<VERSION> .`
- tag it with `sudo docker tag sweagle-elasticsearch:<VERSION> <YOUR_REGISTRY>/sweagle-elasticsearch:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-elasticsearch:<VERSION>`

where <VERSION> is the version of your ElasticSearch package
  - default is 6.8.6 version for SWEAGLE 3.10 and higher

example:

`docker build -t sweagle-elasticsearch:6.8.6 .`

`sudo docker tag sweagle-elasticsearch:6.8.6 docker.sweagle.com:8444/sweagle-elasticsearch:6.8.6`

`sudo docker push docker.sweagle.com:8444/sweagle-elasticsearch:6.8.6`

## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-elasticsearch sweagle-elasticsearch:6.8.6`

- INSIDE
`docker exec -it sweagle-elasticsearch /bin/bash`
then you can run inside your container:
`elasticsearch --version`
`curl http://localhost:9200` to get information about your cluster

- STOP IT
`docker stop sweagle-elasticsearch`

- THEN REMOVE IT
`docker rm sweagle-elasticsearch -f`

## CONFIGURE IT

This container share a volume that contains indexed database for persistence.

## USE IT

Example of docker-compose configuration:

`services:
   sweagle-elasticsearch:
    image: docker.sweagle.com:8444/sweagle-elasticsearch:6.8.6
    networks:
      stack:
    volumes:
      - elasticsearch:/usr/share/elasticsearch/data
    environment:
      - cluster.name=SWEAGLE_cluster
      - network.host=0.0.0.0
      - transport.host=0.0.0.0
      - xpack.security.enabled=false
      - discovery.zen.minimum_master_nodes=1
      - "ES_JAVA_OPTS=-Xms1024m -Xmx1024m"
    networks:
      stack:
`
