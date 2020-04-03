## SWEAGLE INTEGRATION TO GITLAB CI/CD

# DESCRIPTION

This folder provides examples of configuration to include SWEAGLE into a GitLab CI/CD.
SWEAGLE will become the configuration data approval gate after you build your application in DEV and before you deploy it in your Tests and Production environments.
SWEAGLE will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

# PRE-REQUISITES

You should use the scripts provided here with:
- either the scripts provided under the linux or windows directory.
- or the SWEAGLE CLI container

# INSTALLATION WITH CLI

- create a variable DOCKER_AUTH_CONFIG with value equals your SWEAGLE registry authentication settings like:
{
	"auths": {
		"docker.sweagle.com:8444": {
			"auth": "XXX"
		}
	}
}

To generate this file, do a "docker login" from your local machine, then copy content of file: ~/.docker/config.json

More details here: https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#using-statically-defined-credentials


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


# INSTALLATION WITH SCRIPTS

1. Put all linux or windows SWEAGLE shell scripts into one folder of your gitlab repository (for example "/sweagle_scripts")
2. Open the "sweagle.env" script and put your SWEAGLE API token as value for parameter aToken
3. Open file /.gitlab-ci.yml and adapt the 2 tasks "uploadConfiguration" and "deployTestEnvironment" in your own ./gitlab-ci.yml
- For upload task you could take it as a whole, just setting the correct input file/directory,
- For deploy task, just the "before_script" part with parameters should be put in your "before_script" of your own deployment tasks
(only requirement is that these tasks should be in a stage after stage containing "uploadConfiguration")
- Take variables block on top of the file and replace values for variables you are using, like SWEAGLE_SCRIPTS_DIR by the path where you put SWEAGLE scripts

That's all !

# CONTENT

/.gitlab-ci.yml-cli         : Sample GitLab CI/CD pipeline file for cli installlation


/.gitlab-ci.yml-scripts         : Sample GitLab CI/CD pipeline file for script installlation

- Task "uploadConfiguration" is used to upload config files to Sweagle
    - Call input:
        - CONFIG_DIR = Config file or directory containing all files to upload to Sweagle
        - SWEAGLE_PATH = Path in Data Model where you want to put your configuration data

- Task "deployTestEnvironment" is used to deploy to your target environment
    - In part, "before_script", call to SWEAGLE in order to check configuration data that was uploaded before
    - In case the configuration is wrong, SWEAGLE will return an exit code <> 0 that will freeze the pipeline
    - Pre-requisite: uploadConfiguration task must be finished before configuration is checked
    (so it should be in a previous stage of gitlab-ci to avoid parallel work)
    - Call input:
        - SWEAGLE_MDS = Sweagle MDS to check
        - SWEAGLE_VALIDATORS = Sweagle custom validators used to check configuration (as many as needed separated by spaces)
    - In "script" part, call to SWEAGLE in order to retrieve latest valid configuration data
