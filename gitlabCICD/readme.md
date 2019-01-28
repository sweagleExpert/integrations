# SWEAGLE Integration to GitLab CI/CD
DESCRIPTION

This folder provides examples of configuration to include SWEAGLE into a GitLab CI/CD.
SWEAGLE will become the configuration data approval gate after you build your application in DEV and before you deploy it in your Tests and Production environments.
SWEAGLE will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.

INSTALLATION

1. Put all linux or windows SWEAGLE shell scripts into one folder of your gitlab repository (for example "/sweagle_scripts")
2. Open the "sweagle.env" script and put your SWEAGLE API token as value for parameter aToken
3. Open file /.gitlab-ci.yml and adapt the 2 tasks "uploadConfiguration" and "deployTestEnvironment" in your own ./gitlab-ci.yml
- For upload task you could take it as a whole, just setting the correct input file/directory,
- For deploy task, just the "before_script" part with parameters should be put in your "before_script" of your own deployment tasks
(only requirement is that these tasks should be in a stage after stage containing "uploadConfiguration")
- Take variables block on top of the file and replace values for variables you are using, like SWEAGLE_SCRIPTS_DIR by the path where you put SWEAGLE scripts

That's all !

CONTENT

/.gitlab-ci.yml         : Sample GitLab CI/CD pipeline file

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
