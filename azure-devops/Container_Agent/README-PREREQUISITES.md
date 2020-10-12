# SWEAGLE CLI for AZURE DevOps Pipeline

This is how to build an Azure agent on docker container that includes a SWEAGLE CLI.

This is used to work on Azure DevOps pipeline integrated with SWEAGLE.

- Background information on Azure agents
https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser

- Running a self-hosted agent in Docker
https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops


## BUILD IT, TAG IT, PUSH IT

- put in package folder the SWEAGLE CLI for linux

- build container with command
`docker build -t sweagle-azure-cli:<VERSION> .`

- tag it with
`sudo docker tag sweagle-azure-cli:<VERSION> <YOUR_REGISTRY>/sweagle-azure-cli:<VERSION>`

- push it with
`sudo docker push <YOUR_REGISTRY>/sweagle-cli:<VERSION>`

where <VERSION> is the version of your SWEAGLE CLI package

example:

sudo docker build -t sweagle-azure-cli:1.0.0 .

For Docker Hub push:
sudo docker tag sweagle-azure-cli:1.0.0 <YOUR_PROJECT>sweagle-azure-cli:1.0.0
sudo docker push <YOUR_PROJECT>/sweagle-azure-cli:1.0.0


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-cli --env ENV='https://testing.sweagle.com' --env TOKEN='d53de532-a095-4172-XXXX-XXX' -e AZP_URL=https://dev.azure.com/your-project/ -e AZP_TOKEN='XXX' sweagle-azure-cli:1.0.0`

To understand how to generate an Azure token, go to: https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page

- INSIDE
`docker exec -it sweagle-cli /bin/bash`

- STOP IT
`docker stop sweagle-cli`

- THEN REMOVE IT
`docker rm sweagle-cli -f`


# USE IT IN YOUR PIPELINE FROM SWEAGLE REGISTRY IMAGE

Define a new Docker Registry service connection to connect to SWEAGLE registry by following instructions here: https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#sep-docreg

Use values below:

  - Docker registry: https://docker.sweagle.com:8444

  - Docker ID: <your user ID provided by SWEAGLE, in general, your company name>

  - Docker Password: <your docker password provided by SWEAGLE>

  - Service connection name: sweagle_docker_registry

Then, put lines below in your azure-pipelines.yml:

`
resources:         
  containers:
  - container: sweagle-cli
    endpoint: sweagle_docker_registry
    image: 'sweagle-docker/sweagle-azure-cli:1.0.0'

pool:
  vmImage: 'ubuntu-latest'

container: 'sweagle-cli'

steps:

- script: sweagle options --newenv https://testing.sweagle.com --newusername azurePipeline --newtoken 104e6b08-9bbf-4b66-XXXX-XXX
  displayName: 'Configure SWEAGLE CLI'

- script: sweagle info
  displayName: 'Test connection'
`


# OTHERS

- Azure DevOps Extension
 https://docs.microsoft.com/en-us/azure/devops/extend/get-started/node?view=azure-devop

- how to use container in pipelines
https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops
