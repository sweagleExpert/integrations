# SWEAGLE DOCKER images

## DESCRIPTION

This presents samples of Dockerfiles and scripts to build docker images for SWEAGLE components and related external tools (MySQL, Vault, ...) that could be used with it.

Each folder represents a specific image with specific instructions.

Please, note this is only examples and they should be adapted to your specific use, especially if you want to use them in production environments.

An example of full docker-compose file is also provided here if you want to quickly deploy a SWEAGLE instance for test purpose


## TO DO LIST

- Add gid and uid between Vault and Core containers for shared volume

- Add better memory handling in ScriptExecutor and Core with `-XX:+UseContainerSupport` and `-XX:MaxRAMPercentage`
