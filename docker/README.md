# SWEAGLE DOCKER images

## DESCRIPTION

This presents samples of Dockerfiles and scripts to build docker images for SWEAGLE components and related external tools (MySQL, Vault, ...) that could be used with it.

Each folder represents a specific image with specific instructions.

Please, note this is only examples and they should be adapted to your specific use, especially if you want to use them in production environments.

An example of full docker-compose file is also provided here if you want to quickly deploy a SWEAGLE instance for test purpose


## TO DO LIST (IMPROVMENTS)

FOR MORE FLEXIBILITY:

- Add MYSQL_HOST and MONGO_HOST in CORE container to allow use of external service

FOR EASIER SETTINGS (AUTO ADAPTED TO EACH HOST):

- Add better memory handling in ScriptExecutor and Core with `-XX:+UseContainerSupport` and `-XX:MaxRAMPercentage`

TO SIMPLIFY CONTAINERS BUILD STEPS (REMOVE MANUAL OPS):

- Add automatic replacement of values from sweagle-full package in core application.yml

- Use 2 steps container in nginx to unzip full packages and build the target container directly from the full zips

- Add parsers and types in create-tenant container to automatically import them with an ENV setting choice
