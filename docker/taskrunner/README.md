# SWEAGLE TASKRUNNER CONTAINER

## CONTENT

This is instructions to build SWEAGLE TaskRunner container.

## BUILD IT, TAG IT, PUSH IT

- put in `package/bin/taskRunner` folder the SWEAGLE TaskRunner jar file and application.yml
- build container with command `docker build -t sweagle-taskrunner:<VERSION> .`
- tag it with `sudo docker tag sweagle-taskrunner:<VERSION> <YOUR_REGISTRY>/sweagle-taskrunner:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-taskrunner:<VERSION>`

where <VERSION> is the version of your SWEAGLE TaskRunner package


example:

`docker build -t sweagle-taskrunner:1.0.0 .`

`sudo docker tag sweagle-taskrunner:1.0.0 docker.sweagle.com:8444/sweagle-taskrunner:1.0.0`

`sudo docker push docker.sweagle.com:8444/sweagle-taskrunner:1.0.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-taskrunner sweagle-taskrunner:1.0.0`

- INSIDE
`docker exec -it sweagle-taskrunner /bin/sh`
`ps -ef | grep java` => you should see a java taskrunner process

- STOP IT
`docker stop sweagle-taskrunner`

- THEN REMOVE IT
`docker rm sweagle-taskrunner -f`
