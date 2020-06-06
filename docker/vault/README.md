# SWEAGLE VAULT CONTAINER

## CONTENT

This is instructions to build and run sweagle-vault container.
Purpose of this container is to encrypt/decrypt sensitive values managed in SWEAGLE and stored in an external mysql db.


## BUILD IT, TAG IT, PUSH IT

- put your vault binary package in directory /package (be sure to use a package version compatible with SWEAGLE)
- change default values for vault db, user and password in script `startVault.sh` (be sure to use same values as in sweagle-mysql container). You can also activate them in Dockerfile ENV settings if you prefer.
- for test purpose, you may change Dockerfile to only target `vault-local.hcl` file storage instead of mysql
- build container with command "docker build -t sweagle-vault:<VERSION> ."
- tag it with "sudo docker tag sweagle-vault:<VERSION> <YOUR_REGISTRY>/sweagle-vault:<VERSION>"
- push it with "sudo docker push <YOUR_REGISTRY>/sweagle-vault:<VERSION>"

where `<VERSION>` is, for example, the version of your VAULT package


example:

`docker build -t sweagle-vault:0.7.3 .`

`sudo docker tag sweagle-vault:0.7.3 docker.sweagle.com:9444/sweagle-vault:0.7.3`

`sudo docker push docker.sweagle.com:9444/sweagle-vault:0.7.3`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-vault sweagle-vault:0.7.3`

- INSIDE
`docker exec -it sweagle-vault /bin/bash`
then you can run inside your container:
`vault status`

- STOP IT
`docker stop sweagle-vault`

- THEN REMOVE IT
`docker rm sweagle-vault -f`


## CONFIGURE IT

- With environment variables

You can specify VAULT DB settings through environment variables.

example:

`sudo docker run -e VAULT_DB="vault" -e VAULT_DB_USER="XXX" -e VAULT_DB_PASSWORD="XXX" -it sweagle-cli:0.7.3`

Optional environment variables available are:

- VAULT_DB: your vault database name

- VAULT_DB_USER: your vault database username will be defaulted to the value you put in startVault.sh script

- VAULT_DB_PASSWORD: your vault database password, will be defaulted to the value you put in startVault.sh script

- DEBUG_VAULT: this is to display key/tokens values in container logs when doing init. The fact that variable is set to any value will activate the debugging.

It is recommanded to store these setting in your container orchestrator secrets.

IMPORTANT: For VAULT_DB* variables, be sure that they are in sync with what is configured in sweagle-vault container

## USE IT

Docker-compose configuration (listen only on localhost):

`services:
  sweagle-vault:
    image: sweagle-vault:0.7.3
    environment:
      - VAULT_ADDR=http://sweagle-vault:8200
    volumes:
      - vault:/vault
    networks:
      stack:
    depends_on: [ 'sweagle-vault' ]
    links:
      - sweagle-vault`

## TROUBLESHOOTING

- The first time you start Vault, it is recommended to start only 1 replica to have no concurrency when doing init of Vault DB.


- startup process

At startup, sweagle-vault will wait for 1 min for service sweagle-mysql to be available on port 3306.

=> If sweagle-mysql:3306 is not available after this delay, container will fail

Once sweagle-mysql:3306 is available, sweagle-vault will :

  - check its environment settings

  - create vault.hcl config file and start vault service

  - launch init (based on init status) and unseal operations
