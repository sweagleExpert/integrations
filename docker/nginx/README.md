# SWEAGLE NGINX CONTAINER

## CONTENT

This is instructions to build SWEAGLE NGINX container.

## BUILD IT, TAG IT, PUSH IT

- put in `/cli` folder all CLI binaries for linux, MacOS and windows extracted from SWEAGLE package
- put in `/conf`folder all Nginx conf files `sweagle.conf`, `nginx.conf`, `default.conf`
- put in `/ui` folder the SWEAGLE web static files obtained from SWEAGLE package
- build container with command `docker build -t sweagle-nginx:<VERSION> .`
- tag it with `sudo docker tag sweagle-nginx:<VERSION> <YOUR_REGISTRY>/sweagle-nginx:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-nginx:<VERSION>`

where `<VERSION>` is the version of your SWEAGLE TaskRunner package

example:

`docker build -t sweagle-nginx:3.13.0 .`

`sudo docker tag sweagle-nginx:3.13.0 docker.sweagle.com:9444/sweagle-nginx:3.13.0`

`sudo docker push docker.sweagle.com:9444/sweagle-nginx:3.13.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-nginx sweagle-nginx:3.13.0`

- INSIDE
`docker exec -it sweagle-nginx /bin/sh`
`ps -ef | grep java` => you should see a java ml process

- STOP IT
`docker stop sweagle-nginx`

- THEN REMOVE IT
`docker rm sweagle-nginx -f`
