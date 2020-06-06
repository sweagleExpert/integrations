# SWEAGLE SCRIPTEXECUTOR CONTAINER

## CONTENT

This is instructions to build SWEAGLE SCRIPTEXECUTOR container.

## BUILD IT, TAG IT, PUSH IT

- put in `package/bin/scriptExecutor` folder the SWEAGLE ML jar and application.yml files
- build container with command `docker build -t sweagle-scriptexecutor:<VERSION> .`
- tag it with `sudo docker tag sweagle-scriptexecutor:<VERSION> <YOUR_REGISTRY>/sweagle-scriptexecutor:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-scriptexecutor:<VERSION>`

where <VERSION> is the version of your SWEAGLE TaskRunner package


example:

`docker build -t sweagle-scriptexecutor:3.13.0 .`

`sudo docker tag sweagle-scriptexecutor:3.13.0 docker.sweagle.com:9444/sweagle-scriptexecutor:3.13.0`

`sudo docker push docker.sweagle.com:9444/sweagle-scriptexecutor:3.13.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-scriptexecutor sweagle-scriptexecutor:3.13.0`

- INSIDE
`docker exec -it sweagle-scriptexecutor /bin/sh`
`ps -ef | grep java` => you should see a java scriptExecutor process

- STOP IT
`docker stop sweagle-scriptexecutor`

- THEN REMOVE IT
`docker rm sweagle-scriptexecutor -f`
