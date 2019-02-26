# Sweagle Integration to Jenkins
DESCRIPTION

This folder provides examples of configuration to include Sweagle into a Jenkins job.
Sweagle will become the configuration data approval gate before you build your application and deploy it to your various environments.
Sweagle will also fill the tokens with the values linked to deployment context (targeted environment, release, or component, ...)

PRE-REQUISITES

You should use the scripts provided here with the scripts provided under the linux or windows directory.

Script "uploadDirToSweagle" requires no space in the name of your jenkins project.

INSTALLATION

1. Put all linux or windows Sweagle shell scripts into one folder of your jenkins job workspace (for example "/sweagle_scripts") or your git repository (if you are using jenkins pipeline with git plugins)
2. Open the "sweagle.env" script and put your sweagle API token as value for parameter aToken
3. In Jenkins:
    - if you use classic steps/jobs approach
    - configure your project and add Shell steps in order to use Sweagle scripts. Recommended approach is:
        - First step, upload your config files to Sweagle
        - Second step, check configuration status from Sweagle
        - Third step (optional), if you use Sweagle tokens, add a last step to get the configuration files from Sweagle
        - Then, do your build
     - if you use pipelines approach, a sample jenkins file is provided here with content defined below, simply copy, paste and adapt the stages you need in your own pipeline file

By default, Sweagle scripts exits with 1 in case of issues, which will fail the Jenkins job or pipeline.

That's all !

CONTENT

/jenkinsfile         : Sample jenkins declarative pipeline file

- Stage "uploadConfig" is used to upload config files to Sweagle
    - Call input:
        - CONFIG_DIR = Config file or directory containing all files to upload to Sweagle
        - SWEAGLE_PATH = Path in Data Model where you want to put your configuration data

- Stage "CheckConfig" is used to ask Sweagle to check your configuration
    - In case the configuration is wrong, Sweagle will return an exit code <> 0 that will freeze the pipeline
    - Call input:
        - SWEAGLE_MDS = Sweagle MDS to check
        - SWEAGLE_VALIDATORS = Sweagle custom validators used to check configuration (as many as needed separated by spaces)

- Stage "DownloadConfig" is used to retrieve latest valid configuration data before deployment
    - Sweagle will also fill tokens values (if any)
