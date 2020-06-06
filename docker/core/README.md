# SWEAGLE CORE CONTAINER

## CONTENT

This is instructions to build SWEAGLE CORE container.

## BUILD IT, TAG IT, PUSH IT

- put in `/package/bin/core` folder the SWEAGLE CORE jar and application.yml files
- put in `/package/bin/core` folder the JDBC driver jar file
- update application.yml with connection details to
    - MongoDB database  
    - MySQL database
    - Vault container: Vault token can also be provided through ENV variable or will be provided dynamically using shared volume between CORE and Vault
- build container with command `docker build -t sweagle-core:<VERSION> .`
- tag it with `sudo docker tag sweagle-core:<VERSION> <YOUR_REGISTRY>/sweagle-core:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-core:<VERSION>`

where <VERSION> is the version of your SWEAGLE CORE package


example:

`docker build -t sweagle-core:3.13.0 .`

`sudo docker tag sweagle-core:3.13.0 docker.sweagle.com:9444/sweagle-core:3.13.0`

`sudo docker push docker.sweagle.com:9444/sweagle-core:3.13.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-core sweagle-core:3.13.0`

- INSIDE
`docker exec -it sweagle-core /bin/bash`
`ps -ef | grep java` => you should see a java sweagle core process

- STOP IT
`docker stop sweagle-core`

- THEN REMOVE IT
`docker rm sweagle-core -f`


## CONFIGURE IT

With /VAULT volume, shared between Vault and Core containers and that contains result fiels of vault init


With optional environment variables described below:

- VAULT_ROOT_TOKEN: Token to connect to Vaul, extracted from Vault init result file

example:

`sudo docker run -e VAULT_ROOT_TOKEN="XXX" -it sweagle-core:3.13.0`


## TROUBLESHOOTING

- In case of OutOfMemory or error starting the container because not enough memory, you can detect max heap allowable by using instructions below inside your container (by default it should be 25% of your host memory)

`java -XX:+PrintFlagsFinal -version | grep -Ei "maxheapsize|maxram"`

or command below to only display default max and min heap
`java -XX:+PrintFlagsFinal -version|grep -i heapsize|egrep 'Initial|Max'`


For more details, see articles below that summarize how JVM manage memory in container
https://medium.com/adorsys/usecontainersupport-to-the-rescue-e77d6cfea712
