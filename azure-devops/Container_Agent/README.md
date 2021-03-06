## SWEAGLE INTEGRATION TO AZURE DEVOPS

# DESCRIPTION

This folder provides examples of configuration to include SWEAGLE into a Azure DevOps pipeline.
SWEAGLE will become the configuration data approval gate after you build your application in DEV and before you deploy it in your Tests and Production environments.
SWEAGLE will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

# PRE-REQUISITES

You should use the scripts provided here with the SWEAGLE CLI - Azure Agent container.

There are 4 different types of Azure container:

- "simple" type only includes SWEAGLE CLI with required Azure pipeline libraries and environment variables

- "azp3.8.0" type is equivalent to "simple" tag + powershell & azure powershell 3.8.0 libraries if you need to use both SWEAGLE and Powershell or Azure Powershell tasks in same job

- "azp-3.8.0-azcli" type is equivalent to "azp3.8.0" tag + Azure CLI libraries if you need to use both SWEAGLE, Azure Powershell and Azure CLI tasks in same job

Please:
- either, contact SWEAGLE to get an example of image of this container
- or, use sample docker file provided here to build your own one
    - you can look at README-PREREQUISITES.md for instructions to build it

# INSTALLATION WITH CLI

See PDF file "Azure pipeline Sweagle setup.pdf" for more details on how to install and use the CLI container in your Azure DevOps pipeline.

Configure CLI

In order to use the SWEAGLE CLI, you need to configure it to access your tenant with at minimum:
- your SWEAGLE tenant url
- your API token

This can be done in different ways.

1- With an existing db.json file
- put the db.json in a directory of your git project
- ensure you run any CLI command from the directory where db.json is


2- With environment variables
- you can specify SWEAGLE CLI settings through environment variables and create the db.json with command line

Environment variables available are:
- ENV: your SWEAGLE tenant URL
- USERNAME: display name for CLI user
- TOKEN: CLI API token
(optional) if any proxy host to use to go to SWEAGLE URL
- PROVY_HOST
- PROXY_PORT
- PROXY_USER
- PROXY_PASSWORD
(optional) if your SWEAGLE server used self-signed certificate
- IGNORE_SSL (just put the variable, value is not important for this variable)

- run your container and create the db.json in it with command line

sweagle options --newusername <YOUR_USER> --newtoken <YOUR_TOKEN> --newenv <YOUR_URL> --host <PROXY_HOST> --port <PROXY_PORT> --name <PROXY_USERNAME> --key <PROXY_USER_PASSWORD>

If you have self-signed server certificate, don't forget to ignore SSL verification with:
sweagle settings --ignoreSSL


Test CLI access to tenant

- run command: sweagle info

If successfull, it should display a SWEAGLE logo and information about CLI and server versions

You can now run any command from your CLI.

That's all !

# CONTENT

/Azure pipeline Sweagle setup.pdf  : Pdf describing how to configue Azure DevOps pipeline to enable a SWEAGLE container

/.azure-pipelines.yml  : Sample Azure DevOps pipeline file using sweagle cli


/Dockerfile  : Sample docker file to build a container with both Azure Agent and Sweagle CLI inside
