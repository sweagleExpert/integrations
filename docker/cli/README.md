# SWEAGLE CLI CONTAINER

## CONTENT

This is instructions to build and run SWEAGLE CLI container.

Purpose of this container is to be used in GitLabCI, CircleCI, ... or any pipeline tool based on containers, without having to download CLI in each step of your pipeline.


## BUILD IT, TAG IT, PUSH IT

- put in package folder the SWEAGLE CLI binary for linux
- build container with command `docker build -t sweagle-cli:<VERSION> .`
- tag it with `sudo docker tag sweagle-cli:<VERSION> <YOUR_REGISTRY>/sweagle-cli:<VERSION>`
- push it with `sudo docker push <YOUR_REGISTRY>/sweagle-cli:<VERSION>`

where <VERSION> is the version of your SWEAGLE CLI package


example:

`sudo docker build -t sweagle-cli:1.1.0 .`

`sudo docker tag sweagle-cli:1.1.0 docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0`

`sudo docker push docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0`


## TEST IT

- RUN IT
`docker run -d -it --name=sweagle-cli --env ENV='https://testing.sweagle.com' --env TOKEN='XXX' sweagle-cli:1.0.0`

- INSIDE
`docker exec -it sweagle-cli /bin/bash`

- STOP IT
`docker stop sweagle-cli`

- THEN REMOVE IT
`docker rm sweagle-cli -f`


## CONFIGURE IT

1- With an existing db.json file

- mount the db.json to CLI container working folder ("/opt/sweagle")

`sudo docker run -it -v /<DB.JSON_SOURCE_PATH>/db.json:/opt/sweagle/db.json sweagle-cli`

example:

`sudo docker run -it -v /mypath/db.json:/opt/sweagle/db.json sweagle-cli:1.1.0`
`sweagle info`


2- With environment variables

- you can specify SWEAGLE CLI settings through environment variables and db.json will be created at start of the container

example:

`sudo docker run -e ENV="https://testing.sweagle.com" -e TOKEN="XXX" -it sweagle-cli:1.1.0`

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


3- Without db.json or ENV variables

- run your container and create the db.json in it

`sudo docker run -it sweagle-cli:1.1.0`


  - with interactive `sweagle options --setup`


  - or with command line

`root@<YOUR_CONTAINER>:/opt/sweagle# sweagle options --newusername "<YOUR_USER>" --newtoken <YOUR_TOKEN> --newenv <YOUR_URL> --host <PROXY_HOST> --port <PROXY_PORT> --name <PROXY_USERNAME> --key <PROXY_USER_PASSWORD>``

If you have self-signed server certificate, don't forget to ignore SSL verification with:

`sweagle settings --ignoreSSL`

example:

`sweagle options --newusername "Dimitris" --newtoken XXX --newenv https://testing.sweagle.com`

`sweagle settings --ignoreSSL`

`cat db.json`

`sweagle info`


## USE IT

You can test your CLI is well configured by using command:

`sweagle info`

If successfull, it should display a SWEAGLE logo and information about CLI and server versions

You can now run any command from your CLI.


## TROUBLESHOOTING

If you mount a volume with db.json file
When using sweagle cli directly from the directory where you mount your volume , you may get error:
`(node:51) UnhandledPromiseRejectionWarning: Error: EBUSY: resource busy or locked, rename '/.~db.json' -> '/db.json'
(node:51) UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). (rejection id: 1)
(node:51) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.`

You can ignore this error. If you don't want to ignore it, simply copy `db.json` to another directory and run your command from this directory.
