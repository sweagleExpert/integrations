# SWEAGLE CREATE TENANT CONTAINER

## CONTENT

This is instructions to build and run SWEAGLE create-tenant container.
Purpose of this container is to create a tenant on a running SWEAGLE instance.

If the tenant already exists, it won't be created or updated by running this container.


## BUILD IT, TAG IT, PUSH IT

- change values of tenant to create in `createTenant.sh` script, Dockerfile, or through ENV variables when running container
- build container with command "docker build -t sweagle-create-tenant:<VERSION> ."
- tag it with "sudo docker tag sweagle-create-tenant:<VERSION> <YOUR_REGISTRY>/sweagle-create-tenant:<VERSION>"
- push it with "sudo docker push <YOUR_REGISTRY>/sweagle-create-tenant:<VERSION>"

where <VERSION> is the version of your SWEAGLE CREATE TENANT package


example:

`sudo docker build -t sweagle-create-tenant:1.0.1 .``

`sudo docker tag sweagle-create-tenant:1.0.1 docker.sweagle.com:8444/sweagle-create-tenant:1.0.1`

`sudo docker push docker.sweagle.com:8444/sweagle-create-tenant:1.0.1`


## CONFIGURE IT

- With environment variables

You can specify SWEAGLE creation settings through environment variables

example:

sudo docker run -e SWEAGLE_TENANT="myTenant" -e SWEAGLE_ADMIN_USER="myAdmin" -it sweagle-create-tenant:1.0.1

Environment variables available are:

- SWEAGLE_TENANT: your tenant name, default is sweagle (only compulsory value)

Optional:

- SWEAGLE_ADMIN_USER will be defaulted to "admin_${SWEAGLE_TENANT}"

- SWEAGLE_ADMIN_PASSWORD will be defaulted to the value you put in createTenant.sh script

- SWEAGLE_ADMIN_EMAIL will be defaulted to "${SWEAGLE_ADMIN_USER}@${SWEAGLE_TENANT}.com"

- SWEAGLE_URL will be defaulted to "http://sweagle-core:8081"


## USE IT

Docker-compose configuration:

`services:
  sweagle-create-tenant:
    image: docker.sweagle.com:9444/sweagle-create-tenant:1.0.1
    depends_on: ['sweagle-core']
    environment:
      - SWEAGLE_TENANT=sweagle
    links:
      - sweagle-core
    networks:
      stack:`


## TROUBLESHOOTING

At startup, sweagle-create-tenant will wait for 2 mins for service sweagle-core to be available on port 8081.

=> If sweagle-core:8081 is not available after 2 mins, container will fail

Once sweagle-core:8081 is available, sweagle-create-tenant will :

- check its environment settings

- launch curl command to create tenant. If curls fails, it will retry during 2 mins every 10s (for example, curl will fail if sweagle-core service is available and sweagle-core not ready because still starting)

=> If after 2mins, CURL still fails, then container will fail
