# SWEAGLE ML CONTAINER

## CONTENT

This is instructions to build SWEAGLE ML container.

## BUILD IT, TAG IT, PUSH IT

- put in `package/bin/ml` folder the SWEAGLE ML jar and application.yml files
- build container with command `docker build -t sweagle-ml:<VERSION> .`
- tag it with `sudo docker tag sweagle-ml:<VERSION> <YOUR_REGISTRY>/sweagle-ml:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-ml:<VERSION>`

where <VERSION> is the version of your SWEAGLE ML package


example:

`docker build -t sweagle-ml:3.13.0 .`

`sudo docker tag sweagle-ml:3.13.0 docker.sweagle.com:9444/sweagle-ml:3.13.0`

`sudo docker push docker.sweagle.com:9444/sweagle-ml:3.13.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-ml sweagle-ml:3.13.0`

- INSIDE
`docker exec -it sweagle-ml /bin/sh`
`ps -ef | grep java` => you should see a java ml process

- STOP IT
`docker stop sweagle-ml`

- THEN REMOVE IT
`docker rm sweagle-ml -f`
