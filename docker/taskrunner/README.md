# SWEAGLE TASKRUNNER CONTAINER

## CONTENT

This is instructions to build SWEAGLE TaskRunner container.

## BUILD IT, TAG IT, PUSH IT

- put in `package/bin/taskRunner` folder the SWEAGLE TaskRunner jar and application.yml files
- set default values for connection to SWEAGLE CORE container either:
  - in `startTaskRunner.sh`
  - in CONTAINER ENV variables (see CONFIGURE section below)
- build container with command `docker build -t sweagle-taskrunner:<VERSION> .`
- tag it with `sudo docker tag sweagle-taskrunner:<VERSION> <YOUR_REGISTRY>/sweagle-taskrunner:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-taskrunner:<VERSION>`

where <VERSION> is the version of your SWEAGLE TaskRunner package

example:

`docker build -t sweagle-taskrunner:1.0.2 .`

`sudo docker tag sweagle-taskrunner:1.0.2 docker.sweagle.com:9444/sweagle-taskrunner:1.0.2`

`sudo docker push docker.sweagle.com:9444/sweagle-taskrunner:1.0.2`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-taskrunner sweagle-taskrunner:1.0.2`

- INSIDE
`docker exec -it sweagle-taskrunner /bin/sh`
`ps -ef | grep java` => you should see a java taskrunner process

- STOP IT
`docker stop sweagle-taskrunner`

- THEN REMOVE IT
`docker rm sweagle-taskrunner -f`


## CONFIGURE IT

With optional environment variables described below:

- JAVA_OPTS: used to specify any JVM options that you want

- SWEAGLE_CORE: target SWEAGLE CORE host, in container mode, it is `sweagle-core`

- SWEAGLE_TOKEN: SWEAGLE token to connect to CORE

- SWEAGLE_USER: SWEAGLE user to connect to CORE

- SWEAGLE_PASSWORD: SWEAGLE user password to connect to CORE

example:

`sudo docker run -e SWEAGLE_TOKEN="XXX" -it sweagle-taskrunner:1.0.2`


It is recommended to store SWEAGLE connection settings in container secrets.

IMPORTANT: Be sure to use a SWEAGLE active user or token
